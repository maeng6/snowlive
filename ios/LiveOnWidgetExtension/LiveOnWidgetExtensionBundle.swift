import WidgetKit
import SwiftUI

@main
struct LiveOnWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        // 오직 Live Activity만 포함
        LiveOnWidgetExtensionLiveActivity()
    }
}
