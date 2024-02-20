package com.enm10k.anatomy

import PigeonHostApi
import android.graphics.ImageFormat
import android.media.MediaDrm
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Base64
import android.util.Log
import androidContentPmPackageManager
import androidOsBuild
import androidOsBuildVersion
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import org.webrtc.Camera2Enumerator
import org.webrtc.CameraEnumerationAndroid.CaptureFormat
import org.webrtc.EglBase
import org.webrtc.HardwareVideoDecoderFactory
import org.webrtc.HardwareVideoEncoderFactory
import org.webrtc.VideoCodecInfo
import org.webrtc.WebrtcBuildVersion
import rtcCamera
import rtcCodec
import rtcData
import rtcImageFormat
import java.io.BufferedReader
import java.io.FileReader
import java.io.IOException
import java.io.InputStreamReader
import java.util.UUID

// #enddocregion kotlin-class

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(
        @NonNull flutterEngine: FlutterEngine,
    ) {
        // UrlLauncherPlugin.registerWith(registrarFor("io.flutter.plugins.urllauncher.UrlLauncherPlugin"))
        super.configureFlutterEngine(flutterEngine)

        val api = PigeonApiImplementation()
        PigeonHostApi.setUp(flutterEngine.dartExecutor.binaryMessenger, api)
    }

    private fun getVideoEncoderImplementationName(
        factory: HardwareVideoEncoderFactory,
        codecInfo: VideoCodecInfo,
    ): String? {
        val encoder = factory.createEncoder(codecInfo)
        return encoder?.implementationName
    }

    private fun getVideoDecoderImplementationName(
        factory: HardwareVideoDecoderFactory,
        codecInfo: VideoCodecInfo,
    ): String? {
        val decoder = factory.createDecoder(codecInfo)
        return decoder?.implementationName
    }

    // https://developer.android.com/reference/android/graphics/ImageFormat
    private fun imageFormatToName(imageFormat: Int): String {
        return when (imageFormat) {
            ImageFormat.DEPTH16 -> return "DEPTH16"
            ImageFormat.DEPTH_JPEG -> return "DEPTH_JPEG"
            ImageFormat.DEPTH_POINT_CLOUD -> return "DEPTH_POINT_CLOUD"
            ImageFormat.FLEX_RGBA_8888 -> return "FLEX_RGBA_8888"
            ImageFormat.FLEX_RGB_888 -> return "FLEX_RGB_888"
            ImageFormat.HEIC -> return "HEIC"
            ImageFormat.JPEG -> return "JPEG"
            ImageFormat.NV16 -> return "NV16"
            ImageFormat.NV21 -> return "NV21"
            ImageFormat.PRIVATE -> return "PRIVATE"
            ImageFormat.RAW10 -> return "RAW10"
            ImageFormat.RAW12 -> return "RAW12"
            ImageFormat.RAW_PRIVATE -> return "RAW_PRIVATE"
            ImageFormat.RAW_SENSOR -> return "RAW_SENSOR"
            ImageFormat.RGB_565 -> return "RGB_565"
            ImageFormat.UNKNOWN -> return "UNKNOWN"
            ImageFormat.Y8 -> return "Y8"
            ImageFormat.YUV_420_888 -> return "YUV_420_888"
            ImageFormat.YUV_422_888 -> return "YUV_422_888"
            ImageFormat.YUV_444_888 -> return "YUV_444_888"
            ImageFormat.YUY2 -> return "YUY2"
            ImageFormat.YV12 -> return "YV12"
            else -> return "-"
        }
    }

    inner class PigeonApiImplementation : PigeonHostApi {
        override fun getCpuInfo(): String {
            return FileReader("/proc/cpuinfo").use { reader ->
                reader.readLines().joinToString(separator = "\n")
            }
        }

        override fun getWebrtcData(callback: (Result<ByteArray>) -> Unit) {
            Handler(Looper.getMainLooper()).post {
                System.loadLibrary("jingle_peerconnection_so")

                val eglContext = EglBase.create().eglBaseContext

                // Hardware Video Encoder
                val hwEncoderFactory = HardwareVideoEncoderFactory(eglContext, true, true)
                val hwEncoderCodecs =
                    hwEncoderFactory.supportedCodecs.map { codec ->
                        rtcCodec {
                            name = codec.name
                            implementationName = getVideoEncoderImplementationName(hwEncoderFactory, codec) ?: ""
                            this.params.putAll(codec.params)
                            this.scalabilityModes.addAll(codec.scalabilityModes.toList())
                        }
                    }

                // Hardware Video Decoder
                val hwDecoderFactory = HardwareVideoDecoderFactory(eglContext)
                val hwDecoderCodecs =
                    hwDecoderFactory.supportedCodecs.map { codec ->
                        rtcCodec {
                            name = codec.name
                            implementationName = getVideoDecoderImplementationName(hwDecoderFactory, codec) ?: ""
                            this.params.putAll(codec.params)
                            this.scalabilityModes.addAll(codec.scalabilityModes.toList())
                        }
                    }

                // Camera
                val camera2Enumerator = Camera2Enumerator(context)
                val cameraNames = camera2Enumerator.deviceNames.toList()

                val cameras =
                    cameraNames.map { it ->
                        val isFrontFacing = camera2Enumerator.isFrontFacing(it)
                        val isBackFacing = camera2Enumerator.isBackFacing(it)
                        var supportedFormats = camera2Enumerator.getSupportedFormats(it)
                        supportedFormats?.sortWith(
                            compareBy<CaptureFormat?>
                                { it?.frameSize() ?: 0 }.thenBy { it?.width ?: 0 }.thenBy { it?.height ?: 0 },
                        )

                        // Log.d(javaClass.simpleName, "$it $isFrontFacing $isBackFacing $supportedFormats")

                        rtcCamera {
                            this.name = it
                            this.isFrontFacing = isFrontFacing
                            this.isBackFacing = isBackFacing
                            this.imageFormats.addAll(
                                supportedFormats?.map {
                                    rtcImageFormat {
                                        width = it.width
                                        height = it.height
                                        frameRateMin = it.framerate.min.toFloat()
                                        frameRateMax = it.framerate.max.toFloat()
                                        imageFormat = imageFormatToName(it.imageFormat)
                                    }
                                }?.toList() ?: emptyList(),
                            )
                        }
                    }

                callback(
                    Result.success(
                        rtcData {
                            version = "${WebrtcBuildVersion.webrtc_branch}." +
                                "${WebrtcBuildVersion.maint_version}.${WebrtcBuildVersion.webrtc_commit}"
                            this.hwEncoderCodecs.addAll(hwEncoderCodecs)
                            this.hwDecoderCodecs.addAll(hwDecoderCodecs)
                            this.cameraNames.addAll(cameraNames)
                            this.cameras.addAll(cameras)
                        }.toByteArray(),
                    ),
                )
            }
        }

        override fun getSystemProperties(): String {
            return try {
                BufferedReader(
                    InputStreamReader(
                        ProcessBuilder("getprop").start().inputStream,
                    ),
                ).readLines().joinToString(separator = "\n")
            } catch (e: IOException) {
                "$e\n${e.stackTrace}"
            }
        }

        @RequiresApi(Build.VERSION_CODES.O)
        override fun getAndroidBuildData(): ByteArray {
            return androidOsBuild {
                board = Build.BOARD
                bootloader = Build.BOOTLOADER
                brand = Build.BRAND
                model = Build.MODEL
                cpuAbi = Build.CPU_ABI
                cpuAbi2 = Build.CPU_ABI2
                device = Build.DEVICE
                display = Build.DISPLAY ?: ""
                fingerprint = Build.FINGERPRINT
                hardware = Build.HARDWARE
                host = Build.HOST
                id = Build.ID
                manufacturer = Build.MANUFACTURER
                model = Build.MODEL
                if (Build.VERSION_CODES.S <= Build.VERSION.SDK_INT) {
                    odmSku = Build.ODM_SKU
                }
                product = Build.PRODUCT
                serial = Build.SERIAL
                if (Build.VERSION_CODES.S <= Build.VERSION.SDK_INT) {
                    sku = Build.SKU
                    socManufacturer = Build.SOC_MANUFACTURER
                }
                this.supported32BitAbis.addAll(Build.SUPPORTED_32_BIT_ABIS.toList())
                this.supported64BitAbis.addAll(Build.SUPPORTED_64_BIT_ABIS.toList())
                this.supportedAbis.addAll(Build.SUPPORTED_ABIS.toList())
                tags = Build.TAGS
                time = Build.TIME
                type = Build.TYPE
                user = Build.USER
            }.toByteArray()
        }

        override fun getUniqueId(): String {
            return try {
                val widevineUuid = UUID.fromString("edef8ba9-79d6-4ace-a3c8-27dcd51d21ed")
                val byteArray = MediaDrm(widevineUuid).getPropertyByteArray(MediaDrm.PROPERTY_DEVICE_UNIQUE_ID)
                Base64.encodeToString(byteArray, Base64.DEFAULT)
            } catch (e: Exception) {
                Log.d(this.javaClass.simpleName, "$e")
                "f-" + UUID.randomUUID().toString()
            }
        }

        override fun getAndroidPackageManager(): ByteArray {
            return androidContentPmPackageManager {
                this.systemAvailableFeatures.addAll(
                    context.packageManager.systemAvailableFeatures.filter { it.name != null }
                        .map {
                            val flags = "0x" + it.flags.toString(16)

                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                "${it.name} v=${it.version} fl=$flags"
                            } else {
                                "${it.name} fl=$flags"
                            }
                        },
                )
                context.packageManager.systemSharedLibraryNames?.let {
                    this.systemSharedLibraryNames.addAll(
                        it.toList(),
                    )
                }
            }.toByteArray()
        }

        override fun getAndroidBuildVersion(): ByteArray {
            val requiredM = Build.VERSION_CODES.M <= Build.VERSION.SDK_INT
            val securityPatch = if (requiredM) Build.VERSION.SECURITY_PATCH else null

            val v =
                androidOsBuildVersion {
                    if (Build.VERSION_CODES.M <= Build.VERSION.SDK_INT) {
                        baseOs = Build.VERSION.BASE_OS
                    }
                    codename = Build.VERSION.CODENAME
                    incremental = Build.VERSION.INCREMENTAL

                    if (Build.VERSION_CODES.S <= Build.VERSION.SDK_INT) {
                        mediaPerformanceClass = Build.VERSION.MEDIA_PERFORMANCE_CLASS
                    }
                    if (Build.VERSION_CODES.M <= Build.VERSION.SDK_INT) {
                        previewSdkInt = Build.VERSION.PREVIEW_SDK_INT
                    }
                    release = Build.VERSION.RELEASE
                    if (Build.VERSION_CODES.R <= Build.VERSION.SDK_INT) {
                        releaseOrCodename = Build.VERSION.RELEASE_OR_CODENAME
                    }
                    if (Build.VERSION_CODES.TIRAMISU <= Build.VERSION.SDK_INT) {
                        releaseOrPreviewDisplay = Build.VERSION.RELEASE_OR_PREVIEW_DISPLAY
                    }
                    sdk = Build.VERSION.SDK
                    sdkInt = Build.VERSION.SDK_INT
                    if (securityPatch != null) {
                        this.securityPatch = securityPatch
                    }
                }

            // val printer = JsonFormat.printer()
            // printer.print(v)
            return v.toByteArray()
        }
    }
}
