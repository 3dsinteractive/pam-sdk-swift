//
//  NotificationReader.swift
//  NaRaYa
//
//  Created by narongrit kanhanoi on 17/12/2562 BE.
//  Copyright Â© 2562 NaRaYa. All rights reserved.
//

import UIKit

public enum PAMNotificationContentType {
    case reader
    case scheme
    case url
}

public class PAMNotificationReader {

    private let contentType: PAMNotificationContentType
    private let viewController: PAMNotiReaderViewController?
    private let url: String?
    private let pixel: String?

    public init(_ contentType: PAMNotificationContentType, pixel: String?, viewController: PAMNotiReaderViewController) {
        self.contentType = contentType
        self.viewController = viewController
        self.pixel = pixel
        url = nil
    }

    public init(_ contentType: PAMNotificationContentType, pixel: String?, url: String?) {
        self.contentType = contentType
        self.url = url
        self.pixel = pixel
        viewController = nil
    }

    public func getContentType() -> PAMNotificationContentType {
        return contentType
    }

    public func getURL() -> String? {
        return url
    }

    public func getScheme() -> String? {
        return url
    }

    public func getReaderViewController() -> PAMNotiReaderViewController? {
        if contentType != .reader { return nil }
        return viewController
    }

    public func markAsRead() {
        Pam.resolvePixel(pixel)
    }

}
