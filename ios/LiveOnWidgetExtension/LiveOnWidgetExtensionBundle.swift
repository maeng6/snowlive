//
//  LiveOnWidgetExtensionBundle.swift
//  LiveOnWidgetExtension
//
//  Created by 김명식 on 10/26/25.
//

import WidgetKit
import SwiftUI

@main
struct LiveOnWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        LiveOnWidgetExtension()
        LiveOnWidgetExtensionControl()
        LiveOnWidgetExtensionLiveActivity()
    }
}
