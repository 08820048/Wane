cask "wane" do
  version :latest
  sha256 :no_check

  url "https://github.com/08820048/Wane/releases/latest/download/Wane.dmg",
      verified: "github.com/08820048/Wane/"
  name "Wane"
  desc "Ambient progress bars for the current day, week, month, and year"
  homepage "https://github.com/08820048/Wane"

  depends_on macos: :ventura

  app "Wane.app"
end
