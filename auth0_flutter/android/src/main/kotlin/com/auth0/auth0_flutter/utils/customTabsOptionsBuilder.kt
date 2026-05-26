package com.auth0.auth0_flutter.utils

import com.auth0.android.provider.BrowserPicker
import com.auth0.android.provider.CustomTabsOptions

/**
 * Builds a [CustomTabsOptions] from the method channel arguments.
 *
 * Resolution logic:
 * - If `customTabsOptions` map is present in [args], its values (including `allowedBrowsers`) are used.
 * - Otherwise, falls back to top-level `allowedBrowsers` from [args] (deprecated legacy path).
 * - Returns `null` if neither is provided.
 */
fun buildCustomTabsOptions(args: Map<String, Any?>): CustomTabsOptions? {
    val customTabsOptionsMap = args["customTabsOptions"] as? Map<*, *>

    // Resolve allowedBrowsers: customTabsOptions takes precedence over top-level
    val allowedBrowsers = if (customTabsOptionsMap != null) {
        (customTabsOptionsMap["allowedBrowsers"] as? List<*>)?.filterIsInstance<String>().orEmpty()
    } else {
        (args["allowedBrowsers"] as? List<*>)?.filterIsInstance<String>().orEmpty()
    }

    if (customTabsOptionsMap == null && allowedBrowsers.isEmpty()) {
        return null
    }

    val ctBuilder = CustomTabsOptions.newBuilder()

    if (allowedBrowsers.isNotEmpty()) {
        ctBuilder.withBrowserPicker(
            BrowserPicker.newBuilder()
                .withAllowedPackages(allowedBrowsers).build()
        )
    }

    if (customTabsOptionsMap != null) {
        val initialHeight = customTabsOptionsMap["initialHeight"] as? Int
        if (initialHeight != null && initialHeight > 0) {
            ctBuilder.withInitialHeight(initialHeight)
        }

        val resizable = customTabsOptionsMap["resizable"] as? Boolean
        if (resizable != null) {
            ctBuilder.withResizable(resizable)
        }

        val toolbarCornerRadius = customTabsOptionsMap["toolbarCornerRadius"] as? Int
        if (toolbarCornerRadius != null && toolbarCornerRadius > 0) {
            ctBuilder.withToolbarCornerRadius(toolbarCornerRadius)
        }

        val initialWidth = customTabsOptionsMap["initialWidth"] as? Int
        if (initialWidth != null && initialWidth > 0) {
            ctBuilder.withInitialWidth(initialWidth)
        }

        val sideSheetBreakpoint = customTabsOptionsMap["sideSheetBreakpoint"] as? Int
        if (sideSheetBreakpoint != null && sideSheetBreakpoint > 0) {
            ctBuilder.withSideSheetBreakpoint(sideSheetBreakpoint)
        }

        val backgroundInteractionEnabled = customTabsOptionsMap["backgroundInteractionEnabled"] as? Boolean
        if (backgroundInteractionEnabled == true) {
            ctBuilder.withBackgroundInteractionEnabled(true)
        }
    }

    return ctBuilder.build()
}
