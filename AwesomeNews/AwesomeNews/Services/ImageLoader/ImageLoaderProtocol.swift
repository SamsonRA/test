//
//  ImageLoaderProtocol.swift
//  AwesomeNews
//
//  Created by Samson on 09.07.2025.
//

import UIKit

protocol ImageLoaderProtocol {
    func loadImage(from urlString: String) async throws -> UIImage
    func clearCache()
}
