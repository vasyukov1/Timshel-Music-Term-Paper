import UIKit

struct Artist {
    let name: String
    var image: UIImage
    var tracks: [Track] = []
    var albums: [Album] = []
    var info: String
}
