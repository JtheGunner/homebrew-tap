# typed: false
# frozen_string_literal: true

cask "clipkeep" do
  arch arm: "arm64"

  version "0.1.1"
  sha256 "43e82eb3634c4a3380ca2226c64692a1384f8979f9b891d68585aa716b8ec8f9"

  url "https://github.com/JtheGunner/clipkeep/releases/download/v#{version}/Clipkeep-#{version}.zip"
  name "Clipkeep"
  desc "Clipboard history in the menu bar with encrypted storage and secret detection"
  homepage "https://github.com/JtheGunner/clipkeep"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on arch: :arm64
  depends_on macos: ">= :sonoma"

  app "Clipkeep.app"

  zap trash: [
    "~/Library/Application Support/Clipkeep",
    "~/Library/Preferences/li.wuermli.clipkeep.plist",
  ]

  caveats <<~EOS
    Clipkeep is not notarised, so macOS blocks the first launch:
    right-click Clipkeep.app in /Applications, choose "Open" and confirm.
    If there is no "Open" button, use System Settings > Privacy & Security > "Open Anyway".

    Then grant the permissions Clipkeep asks for: Accessibility and Automation
    (both optional) and the Keychain approval. They stay valid across updates
    as long as releases are signed with the same certificate.
  EOS
end
