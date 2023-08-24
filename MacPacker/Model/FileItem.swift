//
//  Archive.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 03.08.23.
//

import Foundation

enum FileItemType: Comparable {
    case file
    case directory
    case archive
    case unknown
}

class FileItem: ObservableObject, Identifiable, Hashable {
    public static let parent: FileItem = FileItem(name: "..", type: .directory)
    let id = UUID()
    var path: URL? = nil
    var virtualPath: String? = nil
    let type: FileItemType
    @Published var name: String
    @Published var ext: String
    @Published var size: Int = -1
    
    //
    // Initializers
    //
    
    /// Constructor used to represent a file that actually exists on the local drive
    /// - Parameters:
    ///   - path: Actual path to the file
    ///   - type: Type of item
    ///   - size: Size of the item
    ///   - name: Name of the titem. If this is nil, then the last path component from path is used
    init(path: URL, type: FileItemType, size: Int? = nil, name: String? = nil) {
        self.path = path
        self.type = type
        self.name = name ?? path.lastPathComponent
        self.size = size ?? -1
        self.ext = ""
        
        if type != .directory {
            self.ext = getExtension(name: name ?? path.lastPathComponent)
        }
    }
    
    /// Constructor used to represent an item that virtually exist. This refers to items that
    /// are not yet extracted, so do not have a local path.
    /// - Parameters:
    ///   - name: Name of the item
    ///   - type: Type of the item
    ///   - virtualPath: The virtual path, for example in an archive
    ///   - size: Size of the item
    init(name: String, type: FileItemType, virtualPath: String? = nil, size: Int? = nil) {
        self.virtualPath = virtualPath
        self.name = name
        self.size = size ?? -1
        self.type = type
        self.ext = ""
        
        if type != .directory {
            self.ext = getExtension(name: name)
        }
        self.name = getName(archiveName: name)
    }
    
    //
    // Functions
    //
    
    private func getName(archiveName: String) -> String {
        var name = archiveName
        
        // in tar, directories have a "/" at the end > remove this first
        if name.last == "/" {
             _ = name.popLast()
        }
        
        // search for the last "/" and then take everything after that
        if var lastSlashIndex = name.lastIndex(of: "/") {
            lastSlashIndex = name.index(after: lastSlashIndex)
            name = String(name[lastSlashIndex...])
        }
        
        return name
    }
    
    private func getExtension(name: String) -> String {
        guard let lastDotIndex = name.lastIndex(of: ".") else {
            return ""
        }
        
        if lastDotIndex == name.startIndex {
            return ""
        }
        
        let extensionStartIndex = name.index(after: lastDotIndex)
        return String(name[extensionStartIndex...])
    }
    
    // opens the item
    // - file > open using system functionality
    // - archive > open in macpacker
    // - directory > open in macpacker
    public func open(_ name: String) {
        
    }
    
    static func == (lhs: FileItem, rhs: FileItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension FileItem: CustomStringConvertible {
    var description: String {
        return path == nil ? "" : path!.absoluteString
    }
}
