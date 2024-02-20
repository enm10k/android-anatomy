# Android Anatomy

https://android-anatomy.pages.dev

TODO: Add screenshots of the site and the app

## Motivation

Unlike Apple devices, Android varies across different devices.  
I occasionally develop apps using WebRTC on Android, and I've encountered issues related to the available hardware video encoders and the camera resolutions specific to each device.  
Often, this detailed information is not included in the device manufacturers' specification sheets.  
This is why I started this project.

## How to use

### Browse the data

Access to https://android-anatomy.pages.dev.

### Contribute to the project

You can share the data of your device using Android app.

> [!NOTE]
> To share data, you need to sign in with a GitHub account.  
> Your GitHub account information will not be made public.


1. Please download the latest binary from the release page of this repository.
2. Launch the app.
3. Press the button at the bottom right of the screen to share the data.

---

## Data to collect

- [android.os.Build](https://developer.android.com/reference/android/os/Build)
- [android.os.Build.VERSION](https://developer.android.com/reference/android/os/Build.VERSION)
- CPU info ... `/proc/cpuinfo`
- WebRTC
  - version of libwebrtc to be used to collect data
  - hardware video encoder
  - hardware video decoder
  - camera and supported format (resolution, frame rate, image format)
- [System Properties](https://source.android.com/docs/core/architecture/configuration)
  - **To avoid collecting properties set by users, only properties starting with 'ro' and 'vendor' will be collected.**

> [!TIP]
> Data may be added in future development.
> - android.content.pm.PackageManager
> - android.net.wifi.WifiManager
> - Built-in audio device
> - Bluetooth
> - ...
