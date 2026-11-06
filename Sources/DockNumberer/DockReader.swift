import Foundation

/// Reads the ordered list of pinned apps from the user's Dock.
enum DockReader {
    /// Returns up to `limit` app URLs in Dock order (left-to-right / top-to-bottom).
    static func pinnedApps(limit: Int = 10) -> [URL] {
        guard let tiles = CFPreferencesCopyAppValue("persistent-apps" as CFString,
                                                    "com.apple.dock" as CFString) as? [[String: Any]]
        else { return [] }

        var urls: [URL] = []
        for tile in tiles {
            // Skip spacers and anything that isn't a regular app tile.
            guard (tile["tile-type"] as? String) == "file-tile",
                  let data = tile["tile-data"] as? [String: Any],
                  let file = data["file-data"] as? [String: Any],
                  let str = file["_CFURLString"] as? String,
                  let url = URL(string: str),
                  url.isFileURL
            else { continue }
            urls.append(url)
            if urls.count == limit { break }
        }
        return urls
    }
}
