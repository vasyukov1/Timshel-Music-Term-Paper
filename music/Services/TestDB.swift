import Foundation

func getDocumentsFilePath(filename: String) -> String {
    let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    return (documentsDirectory as NSString).appendingPathComponent("\(filename).txt")
}
