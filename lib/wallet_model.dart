class WalletModel {
  double availableBalance;
  double pendingBalance;
  DateTime? pendingReleaseDate;

  WalletModel({
    this.availableBalance = 0.0,
    this.pendingBalance = 0.0,
    this.pendingReleaseDate,
  });

  Map<String, dynamic> toJson() => {
    'availableBalance': availableBalance,
    'pendingBalance': pendingBalance,
    'pendingReleaseDate': pendingReleaseDate?.toIso8601String(),
  };

  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
    availableBalance: json['availableBalance'] ?? 0.0,
    pendingBalance: json['pendingBalance'] ?? 0.0,
    pendingReleaseDate: json['pendingReleaseDate'] != null 
        ? DateTime.parse(json['pendingReleaseDate'])
        : null,
  );
}