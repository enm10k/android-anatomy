syntax = "proto3";

message AndroidOsBuildVersion {
  string base_os = 1;
  string codename = 2;
  string incremental = 3;
  int32 media_performance_class = 4;
  int32 preview_sdk_int = 5;
  string release = 6;
  string release_or_codename = 7;
  string release_or_preview_display = 8;
  string sdk = 9;
  int32 sdk_int = 10;
  string security_patch = 11;
}

message AndroidOsBuild {
  string board = 1;
  string bootloader = 2;
  string brand = 3;
  string cpu_abi = 4;
  string cpu_abi2 = 5;
  string device = 6;
  string display = 7;
  string fingerprint = 8;
  string hardware = 9;
  string host = 10;
  string id = 11;
  string manufacturer = 12;
  string model = 13;
  string odm_sku = 14;
  string product = 15;
  string radio = 16;
  string serial = 17;
  string sku = 18;
  string soc_manufacturer = 19;
  string soc_model = 20;
  repeated string supported_32bit_abis = 21;
  repeated string supported_64bit_abis = 22;
  repeated string supported_abis = 24;
  string tags = 25;
  int64 time = 26;
  string type = 27;
  string user = 28;
}

message AndroidContentPmPackageManager {
  repeated string system_available_features = 1;
  repeated string system_shared_library_names = 2;
}

message RtcCodec {
  string name = 1;
  string implementation_name = 2; // Optional
  map<string, string> params = 3; // Optional
  repeated int32 scalability_modes = 4;
}

message RtcImageFormat {
  int32 width = 1;
  int32 height = 2;
  float frame_rate_min = 3;
  float frame_rate_max = 4;
  string image_format = 5;
}

message RtcCamera {
  string name = 1;
  bool is_front_facing = 2;
  bool is_back_facing = 3;
  repeated RtcImageFormat image_formats = 4;
}

message RtcData {
  string version = 1;
  repeated RtcCodec hw_encoder_codecs = 2;
  repeated RtcCodec hw_decoder_codecs = 3;
  repeated string camera_names = 4;
  repeated RtcCamera cameras = 5;
}
