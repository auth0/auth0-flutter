package com.auth0.auth0_flutter

import com.auth0.android.provider.BrowserPicker
import com.auth0.android.provider.CustomTabsOptions
import com.auth0.auth0_flutter.utils.buildCustomTabsOptions
import org.hamcrest.CoreMatchers.equalTo
import org.hamcrest.CoreMatchers.nullValue
import org.hamcrest.CoreMatchers.notNullValue
import org.hamcrest.MatcherAssert.assertThat
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class CustomTabsOptionsBuilderTest {

    private fun getPrivateField(obj: Any, fieldName: String): Any? {
        val field = obj.javaClass.getDeclaredField(fieldName)
        field.isAccessible = true
        return field.get(obj)
    }

    private fun getPrivateIntField(obj: Any, fieldName: String): Int {
        val field = obj.javaClass.getDeclaredField(fieldName)
        field.isAccessible = true
        return field.getInt(obj)
    }

    private fun getPrivateBooleanField(obj: Any, fieldName: String): Boolean {
        val field = obj.javaClass.getDeclaredField(fieldName)
        field.isAccessible = true
        return field.getBoolean(obj)
    }

    @Test
    fun `returns null when neither customTabsOptions nor allowedBrowsers is provided`() {
        val args = hashMapOf<String, Any?>()
        val result = buildCustomTabsOptions(args)
        assertThat(result, nullValue())
    }

    @Test
    fun `returns null when allowedBrowsers is empty and customTabsOptions is absent`() {
        val args = hashMapOf<String, Any?>("allowedBrowsers" to listOf<String>())
        val result = buildCustomTabsOptions(args)
        assertThat(result, nullValue())
    }

    @Test
    fun `builds options with initialHeight`() {
        val args = hashMapOf<String, Any?>(
            "customTabsOptions" to mapOf(
                "initialHeight" to 700,
                "allowedBrowsers" to listOf<String>()
            )
        )
        val result = buildCustomTabsOptions(args)
        assertThat(result, notNullValue())
        assertThat(getPrivateIntField(result!!, "initialHeight"), equalTo(700))
    }

    @Test
    fun `builds options with all partial tab properties`() {
        val args = hashMapOf<String, Any?>(
            "customTabsOptions" to mapOf(
                "initialHeight" to 700,
                "resizable" to false,
                "toolbarCornerRadius" to 16,
                "initialWidth" to 500,
                "sideSheetBreakpoint" to 840,
                "backgroundInteractionEnabled" to true,
                "allowedBrowsers" to listOf("com.android.chrome")
            )
        )
        val result = buildCustomTabsOptions(args)
        assertThat(result, notNullValue())
        assertThat(getPrivateIntField(result!!, "initialHeight"), equalTo(700))
        assertThat(getPrivateIntField(result, "toolbarCornerRadius"), equalTo(16))
        assertThat(getPrivateIntField(result, "initialWidth"), equalTo(500))
        assertThat(getPrivateIntField(result, "sideSheetBreakpoint"), equalTo(840))
        assertThat(getPrivateBooleanField(result, "backgroundInteractionEnabled"), equalTo(true))
    }

    @Test
    fun `uses allowedBrowsers from customTabsOptions when both are provided`() {
        val args = hashMapOf<String, Any?>(
            "allowedBrowsers" to listOf("org.mozilla.firefox"),
            "customTabsOptions" to mapOf(
                "initialHeight" to 500,
                "allowedBrowsers" to listOf("com.android.chrome")
            )
        )
        val result = buildCustomTabsOptions(args)
        assertThat(result, notNullValue())

        val picker = getPrivateField(result!!, "browserPicker") as BrowserPicker
        val packagesField = picker.javaClass.getDeclaredField("allowedPackages")
        packagesField.isAccessible = true
        @Suppress("UNCHECKED_CAST")
        val packages = packagesField.get(picker) as List<String>
        assertThat(packages, equalTo(listOf("com.android.chrome")))
    }

    @Test
    fun `falls back to top-level allowedBrowsers when customTabsOptions is absent`() {
        val args = hashMapOf<String, Any?>(
            "allowedBrowsers" to listOf("com.android.chrome", "org.mozilla.firefox")
        )
        val result = buildCustomTabsOptions(args)
        assertThat(result, notNullValue())

        val picker = getPrivateField(result!!, "browserPicker") as BrowserPicker
        val packagesField = picker.javaClass.getDeclaredField("allowedPackages")
        packagesField.isAccessible = true
        @Suppress("UNCHECKED_CAST")
        val packages = packagesField.get(picker) as List<String>
        assertThat(packages, equalTo(listOf("com.android.chrome", "org.mozilla.firefox")))
    }

    @Test
    fun `ignores initialHeight when zero or negative`() {
        val args = hashMapOf<String, Any?>(
            "customTabsOptions" to mapOf(
                "initialHeight" to 0,
                "allowedBrowsers" to listOf<String>()
            )
        )
        val result = buildCustomTabsOptions(args)
        assertThat(result, notNullValue())
        assertThat(getPrivateIntField(result!!, "initialHeight"), equalTo(0))
    }

    @Test
    fun `handles missing optional fields gracefully`() {
        val args = hashMapOf<String, Any?>(
            "customTabsOptions" to mapOf(
                "allowedBrowsers" to listOf<String>()
            )
        )
        val result = buildCustomTabsOptions(args)
        assertThat(result, notNullValue())
        assertThat(getPrivateIntField(result!!, "initialHeight"), equalTo(0))
        assertThat(getPrivateIntField(result, "initialWidth"), equalTo(0))
        assertThat(getPrivateIntField(result, "sideSheetBreakpoint"), equalTo(0))
        assertThat(getPrivateBooleanField(result, "backgroundInteractionEnabled"), equalTo(false))
    }
}
