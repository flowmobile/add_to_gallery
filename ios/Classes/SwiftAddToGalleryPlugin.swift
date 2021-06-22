import Flutter
import UIKit
import Photos

public class SwiftAddToGalleryPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "add_to_gallery", binaryMessenger: registrar.messenger())
        let instance = SwiftAddToGalleryPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        if call.method == "addToGallery" {
            self.addToAssetCollection(call, result)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func addToAssetCollection(
        _ call: FlutterMethodCall,
        _ result: @escaping FlutterResult
    ) {
        let permissionStatus = PHPhotoLibrary.authorizationStatus()
        if permissionStatus != .authorized {
            result(FlutterError(code: "permissions", message: "Please grant PHPhotoLibrary permission", details: nil))
        } else {
            let args = call.arguments as? Dictionary<String, Any>
            let imagePath = args!["path"] as! String
            let albumName = args!["album"] as! String
            if let album = fetchAssetCollectionForAlbum(albumName) {
                self.addFileToAssetCollection(imagePath, album, result)
            } else {
                createAssetCollectionForAlbum(albumName: albumName) { (error) in
                    guard error == nil else {
                        result(FlutterError(code: "album_not_available", message: "Album Not Available", details: nil))
                        return
                    }
                    if let album = self.fetchAssetCollectionForAlbum(albumName){
                        self.addFileToAssetCollection(imagePath, album, result)
                    } else {
                        result(FlutterError(code: "could_not_create_album", message: "Could Not Create Album", details: nil))
                    }
                }
            }
        }
    }
    
    private func addFileToAssetCollection(
        _ imagePath: String,
        _ album: PHAssetCollection?,
        _ result: @escaping FlutterResult
    ) {
        let url = URL(fileURLWithPath: imagePath)
        PHPhotoLibrary.shared().performChanges({
            let assetCreationRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
            if (album != nil) {
                guard let assetCollectionChangeRequest = PHAssetCollectionChangeRequest(for: album!),
                    let createdAssetPlaceholder = assetCreationRequest?.placeholderForCreatedAsset else {
                        return
                    }
                assetCollectionChangeRequest.addAssets(NSArray(array: [createdAssetPlaceholder]))
            }
        }) { (success, error) in
            if success {
                result(imagePath) // Success!
            } else {
                result(FlutterError(code: "could_not_save_file", message: "Could Not Save File", details: nil))
            }
        }
    }

    private func fetchAssetCollectionForAlbum(
        _ albumName: String
    ) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        return nil
    }
    
    private func createAssetCollectionForAlbum(
        albumName: String,
        completion: @escaping (Error?) -> ()
    ) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
        }) { (_, error) in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }

}
