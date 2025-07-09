//
//  WebViewProtocols.swift
//  AwesomeNews
//
//  Created by Samson on 09.07.2025.
//

import Foundation

protocol WebViewProtocol: AnyObject {
    func loadURL(_ url: URL)
    func showError(message: String)
}
