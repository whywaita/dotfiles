import os
import subprocess
import tempfile
import tomllib
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "dot_codex/scripts/codex-update-config.sh"
TEMPLATE = ROOT / "dot_codex/config.template.toml"


class UpdateConfigTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.home = Path(self.tmp.name)
        self.config = self.home / ".codex/config.toml"
        self.template = tomllib.loads(TEMPLATE.read_text(encoding="utf-8"))

    def run_script(self):
        env = dict(os.environ, HOME=str(self.home))
        subprocess.run([str(SCRIPT)], env=env, check=True)
        return tomllib.loads(self.config.read_text(encoding="utf-8"))

    def write_config(self, text):
        self.config.parent.mkdir(parents=True, exist_ok=True)
        self.config.write_text(text, encoding="utf-8")

    def test_fresh_config_matches_template(self):
        self.assertEqual(self.run_script(), self.template)

    def test_template_values_override_existing(self):
        self.write_config('model = "stale-model"\n')
        self.assertEqual(self.run_script()["model"], self.template["model"])

    def test_keeps_keys_not_in_template(self):
        self.write_config(
            '[projects."/tmp/a b"]\ntrust_level = "trusted"\n'
            '[plugins."x@y"]\nenabled = true\n'
        )
        merged = self.run_script()
        self.assertEqual(merged["projects"]["/tmp/a b"]["trust_level"], "trusted")
        self.assertTrue(merged["plugins"]["x@y"]["enabled"])

    def test_existing_notify_is_preserved(self):
        # Codex Computer Use wraps the previous notify command in its own;
        # re-running setup must not drop that wrapper.
        wrapped = ["/path/to/SkyComputerUseClient", "turn-ended", "--previous-notify", "[]"]
        self.write_config(f"notify = {wrapped!r}\n".replace("'", '"'))
        self.assertEqual(self.run_script()["notify"], wrapped)


if __name__ == "__main__":
    unittest.main()
