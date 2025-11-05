// D:/flutter projects/pashuu/android/fix-namespace.gradle.kts

import androidx.fragment.app.replace
import com.android.build.gradle.LibraryExtension
import org.gradle.api.Plugin
import org.gradle.api.Project
import org.gradle.kotlin.dsl.findByType

/**
 * This script fixes old plugins that were not updated for the Android Gradle Plugin 8.0
 * by setting a default 'namespace' if it is missing.
 */
fun Project.fixOldPlugins() {
    plugins.withType<com.android.build.gradle.LibraryPlugin> {
        extensions.findByType<LibraryExtension>()?.let { android ->
            if (android.namespace == null) {
                android.namespace = "com.example.${project.name.replace('-', '_')}"
            }
        }
    }
}

allprojects {
    afterEvaluate {
        project.fixOldPlugins()
    }
}
