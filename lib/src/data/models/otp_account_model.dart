import '../../domain/entities/otp_account.dart';

/// Data-layer version of OtpAccount: adds JSON (de)serialization for storage.
/// Kept separate from the entity so the domain stays free of persistence concerns.
class OtpAccountModel extends OtpAccount {
  const OtpAccountModel({
    required super.id,
    required super.label,
    required super.issuer,
    required super.secret,
  });

  factory OtpAccountModel.fromJson(Map<String, dynamic> json) {
    return OtpAccountModel(
      id: json['id'] as String,
      label: json['label'] as String,
      issuer: json['issuer'] as String,
      secret: json['secret'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'issuer': issuer,
        'secret': secret,
      };

  factory OtpAccountModel.fromEntity(OtpAccount a) => OtpAccountModel(
        id: a.id,
        label: a.label,
        issuer: a.issuer,
        secret: a.secret,
      );
}
