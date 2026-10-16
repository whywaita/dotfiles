import os
import pty
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WRAPPER = ROOT / "dot_pi/scripts/pi-worktree.sh"


class WorktreeTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.base = Path(self.tmp.name).resolve()
        self.repo = self.base / "repo with spaces"
        self.repo.mkdir()
        self.git("init", "-q")
        self.git(
            "-c",
            "user.name=Test",
            "-c",
            "user.email=test@example.invalid",
            "-c",
            "commit.gpgsign=false",
            "commit",
            "--allow-empty",
            "-qm",
            "initial",
        )
        self.bin = self.base / "bin"
        self.bin.mkdir()
        # pi has no working-directory option, so the fake records its cwd.
        fake = self.bin / "pi"
        fake.write_text("""#!/bin/bash
{ pwd -P; [ $# -eq 0 ] || printf '%s\\n' "$@"; } > "$TEST_LOG"
case "${TEST_CHANGE:-}" in
  detached) git checkout --detach -q ;;
  dirty) printf 'valuable data' > untracked ;;
  ignored) printf 'secret data' > secret; printf 'secret\\n' >> "$(git rev-parse --git-path info/exclude)" ;;
esac
exit "${TEST_EXIT:-0}"
""")
        fake.chmod(0o755)
        self.log = self.base / "args"
        self.env = {
            **os.environ,
            "PATH": f"{self.bin}:{os.environ['PATH']}",
            "TEST_LOG": str(self.log),
        }

    def git(self, *args):
        return subprocess.check_output(
            ["git", "-C", str(self.repo), *args], text=True
        ).strip()

    def run_wrapper(self, name="task", answer=None, **env):
        master, slave = pty.openpty()
        self.addCleanup(os.close, master)
        try:
            if answer is not None:
                os.write(master, answer.encode())
            result = subprocess.run(
                check=False,
                args=["bash", str(WRAPPER), name],
                cwd=self.repo,
                env={**self.env, **env},
                stdin=slave if answer is not None else subprocess.DEVNULL,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                timeout=10,
            )
        finally:
            os.close(slave)
        return result

    def path(self):
        return Path(self.log.read_text().splitlines()[0])

    def args(self):
        return self.log.read_text().splitlines()[1:]

    def test_keep_and_starting_commit(self):
        result = self.run_wrapper(answer="k\n")
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertEqual(self.path(), self.repo / ".worktrees/task")
        self.assertTrue(self.path().is_dir())
        self.assertEqual(
            self.git("rev-parse", "HEAD"), self.git("rev-parse", "pi/task")
        )
        self.assertIn("pi --resume", result.stdout)

    def test_worktree_is_excluded_from_status(self):
        result = self.run_wrapper()
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertEqual(self.git("status", "--porcelain"), "")

    def test_remove_preserves_branch(self):
        result = self.run_wrapper(answer="r\n")
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertFalse(self.path().exists())
        self.git("show-ref", "--verify", "refs/heads/pi/task")

    def test_detached_head_is_kept(self):
        result = self.run_wrapper(answer="r\n", TEST_CHANGE="detached")
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertTrue(self.path().is_dir())

    def test_dirty_remove_requires_confirmation(self):
        result = self.run_wrapper(answer="r\nno\n", TEST_CHANGE="dirty")
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertEqual((self.path() / "untracked").read_text(), "valuable data")

    def test_confirmed_dirty_remove(self):
        result = self.run_wrapper(answer="r\nDELETE\n", TEST_CHANGE="dirty")
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertFalse(self.path().exists())

    def test_ignored_files_are_protected(self):
        result = self.run_wrapper(answer="r\nno\n", TEST_CHANGE="ignored")
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertTrue((self.path() / "secret").exists())

    def test_noninteractive_keeps_and_preserves_exit_code(self):
        result = self.run_wrapper(TEST_EXIT="42")
        self.assertEqual(result.returncode, 42, result.stdout)
        self.assertTrue(self.path().is_dir())

    def test_collision_does_not_launch_pi(self):
        self.run_wrapper()
        self.log.unlink()
        result = self.run_wrapper()
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.log.exists())

    def test_invalid_name(self):
        result = self.run_wrapper(name="../escape")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.log.exists())

    def test_generated_name(self):
        result = subprocess.run(
            check=False,
            args=["bash", str(WRAPPER)],
            cwd=self.repo,
            env=self.env,
            stdin=subprocess.DEVNULL,
            capture_output=True,
            text=True,
            timeout=10,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertRegex(self.path().name, r"^session-\d{8}-\d{6}-\d+$")
        self.assertEqual(self.args(), [])

    def test_original_changes_stay_in_original_checkout(self):
        (self.repo / "local-only").write_text("original work")
        result = self.run_wrapper()
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertFalse((self.path() / "local-only").exists())
        self.assertEqual((self.repo / "local-only").read_text(), "original work")
        self.assertEqual(self.git("status", "--porcelain"), "?? local-only")

    def test_session_selection_overrides_rejected(self):
        for flag in ("--session-dir", "--session=abc", "--fork", "-c", "-r"):
            result = subprocess.run(
                check=False,
                args=["bash", str(WRAPPER), "task", flag],
                cwd=self.repo,
                env=self.env,
                capture_output=True,
                text=True,
            )
            self.assertNotEqual(result.returncode, 0, flag)
            self.assertFalse(self.log.exists(), flag)

    def test_setup_and_shell_worktree_routing(self):
        isolated_home = self.base / "isolated-home"
        isolated_home.mkdir()
        env = {**self.env, "HOME": str(isolated_home)}
        setup = subprocess.run(
            check=False,
            args=["bash", str(ROOT / "scripts/setup-pi.sh")],
            env=env,
            capture_output=True,
            text=True,
        )
        self.assertEqual(setup.returncode, 0, setup.stderr)
        for name in ("worktree-shell.sh", "pi-worktree.sh"):
            self.assertTrue((isolated_home / ".pi" / name).is_symlink())
        for shell, flag in (("bash", "--worktree"), ("zsh", "-w")):
            result = subprocess.run(
                check=False,
                args=[
                    shell,
                    "-c",
                    'set -e; source "$HOME/.pi/worktree-shell.sh"; pi "$1" -- "two words"',
                    "test",
                    flag,
                ],
                cwd=self.repo,
                env=env,
                stdin=subprocess.DEVNULL,
                capture_output=True,
                text=True,
                timeout=10,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertTrue(self.path().is_dir())
            self.assertEqual(self.args(), ["two words"])

    def test_shell_passthrough(self):
        shell_file = ROOT / "dot_pi/worktree-shell.sh"
        for shell in ("bash", "zsh"):
            result = subprocess.run(
                check=False,
                args=[
                    shell,
                    "-c",
                    'set -e; source "$1"; pi -p "two words"',
                    "test",
                    str(shell_file),
                ],
                cwd=self.base,
                env=self.env,
                capture_output=True,
                text=True,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(self.path(), self.base)
            self.assertEqual(self.args(), ["-p", "two words"])


if __name__ == "__main__":
    unittest.main()
