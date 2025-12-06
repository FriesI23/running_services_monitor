package me.biplobsd.rsm

import android.content.pm.PackageManager
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import rikka.shizuku.Shizuku
import java.io.BufferedReader
import java.io.InputStreamReader

class MainActivity : FlutterActivity(), Shizuku.OnRequestPermissionResultListener {
    private val CHANNEL = "com.runningservices/shizuku"
    private val STREAM_CHANNEL = "com.runningservices/shizuku_stream"
    private val SHIZUKU_PERMISSION_REQUEST_CODE = 1001
    private var pendingPermissionResult: MethodChannel.Result? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    private var isRootAvailable: Boolean? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        Shizuku.addRequestPermissionResultListener(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "runCommand" -> {
                    val command = call.argument<String>("command")
                    if (command != null) {
                        runCommandInBackground(command, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "Command cannot be null", null)
                    }
                }
                "pingBinder" -> {
                    try {
                        result.success(Shizuku.pingBinder())
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                "checkRootPermission" -> {
                    CoroutineScope(Dispatchers.IO).launch {
                        val hasRoot = checkRootAvailable()
                        withContext(Dispatchers.Main) {
                            result.success(hasRoot)
                        }
                    }
                }
                "requestRootPermission" -> {
                    CoroutineScope(Dispatchers.IO).launch {
                        val hasRoot = checkRootAvailable()
                        withContext(Dispatchers.Main) {
                            result.success(hasRoot)
                        }
                    }
                }
                "checkPermission" -> {
                    try {
                        if (Shizuku.isPreV11()) {
                            result.success(false)
                        } else {
                            result.success(Shizuku.checkSelfPermission() == PackageManager.PERMISSION_GRANTED)
                        }
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                "requestPermission" -> {
                    try {
                        if (Shizuku.checkSelfPermission() == PackageManager.PERMISSION_GRANTED) {
                            result.success(true)
                        } else if (Shizuku.shouldShowRequestPermissionRationale()) {
                            pendingPermissionResult = result
                            Shizuku.requestPermission(SHIZUKU_PERMISSION_REQUEST_CODE)
                        } else {
                            pendingPermissionResult = result
                            Shizuku.requestPermission(SHIZUKU_PERMISSION_REQUEST_CODE)
                        }
                    } catch (e: Exception) {
                        result.error("PERMISSION_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, STREAM_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    if (events == null) return
                    
                    val command = arguments as? String
                    if (command == null) {
                        events.error("INVALID_ARGUMENT", "Command cannot be null", null)
                        events.endOfStream()
                        return
                    }

                    CoroutineScope(Dispatchers.IO).launch {
                        try {
                            executeShizukuCommandWithStream(command, events)
                            withContext(Dispatchers.Main) {
                                events.endOfStream()
                            }
                        } catch (e: Exception) {
                            withContext(Dispatchers.Main) {
                                events.error("EXECUTION_ERROR", e.message, null)
                                events.endOfStream()
                            }
                        }
                    }
                }

                override fun onCancel(arguments: Any?) {
                }
            }
        )
    }

    override fun onDestroy() {
        super.onDestroy()
        Shizuku.removeRequestPermissionResultListener(this)
    }

    override fun onRequestPermissionResult(requestCode: Int, grantResult: Int) {
        if (requestCode == SHIZUKU_PERMISSION_REQUEST_CODE) {
            val granted = grantResult == PackageManager.PERMISSION_GRANTED
            pendingPermissionResult?.success(granted)
            pendingPermissionResult = null
        }
    }

    private fun runCommandInBackground(command: String, result: MethodChannel.Result) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val output = executeShizukuCommand(command)
                withContext(Dispatchers.Main) {
                    result.success(output)
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("EXECUTION_ERROR", e.message, null)
                }
            }
        }
    }

    private fun executeShizukuCommand(command: String): String {
        if (Shizuku.pingBinder()) {
            try {
                val process = Shizuku.newProcess(arrayOf("sh", "-c", command), null, null)
                val reader = BufferedReader(InputStreamReader(process.inputStream))
                val output = StringBuilder()
                var line: String?

                while (reader.readLine().also { line = it } != null) {
                    output.append(line).append("\n")
                }

                process.waitFor()
                return output.toString()
            } catch (e: Exception) {
                if (checkRootAvailable()) {
                    return executeRootCommand(command)
                }
                throw e
            }
        } else if (checkRootAvailable()) {
            return executeRootCommand(command)
        } else {
            throw Exception("Shizuku is not running and root is not available")
        }
    }

    private fun checkRootAvailable(): Boolean {
        if (isRootAvailable != null) {
            return isRootAvailable!!
        }

        isRootAvailable = try {
            val process = Runtime.getRuntime().exec(arrayOf("su", "-c", "id"))
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            val output = reader.readLine()
            process.waitFor()
            reader.close()
            output?.contains("uid=0") == true
        } catch (e: Exception) {
            false
        }

        return isRootAvailable!!
    }

    private fun executeRootCommand(command: String): String {
        val process = Runtime.getRuntime().exec(arrayOf("su", "-c", command))
        val reader = BufferedReader(InputStreamReader(process.inputStream))
        val output = StringBuilder()
        var line: String?

        while (reader.readLine().also { line = it } != null) {
            output.append(line).append("\n")
        }

        process.waitFor()
        reader.close()
        return output.toString()
    }

    private fun executeShizukuCommandWithStream(command: String, events: EventChannel.EventSink) {
        val process: Process
        
        if (Shizuku.pingBinder()) {
            process = Shizuku.newProcess(arrayOf("sh", "-c", command), null, null)
        } else if (checkRootAvailable()) {
            process = Runtime.getRuntime().exec(arrayOf("su", "-c", command))
        } else {
            throw Exception("Shizuku is not running and root is not available")
        }

        val reader = BufferedReader(InputStreamReader(process.inputStream))
        var line: String?

        while (reader.readLine().also { line = it } != null) {
            line?.let {
                val finalLine = it
                mainHandler.post {
                    events.success(finalLine)
                }
            }
        }

        val errorReader = BufferedReader(InputStreamReader(process.errorStream))
        while (errorReader.readLine().also { line = it } != null) {
            line?.let {
                val finalLine = it
                mainHandler.post {
                    events.success("ERROR: $finalLine")
                }
            }
        }

        process.waitFor()
        reader.close()
        errorReader.close()
    }
}

