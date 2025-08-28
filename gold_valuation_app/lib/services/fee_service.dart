class FeeService {
  // Computes fee: ₹250 minimum OR ₹150 per ₹1,00,000 loan amount, rounded up
  // to next lakh, whichever is higher.
  static int computeFeeRupees(int loanAmountRupees) {
    if (loanAmountRupees <= 0) return 250;
    final double lakhs = loanAmountRupees / 100000.0;
    final int chargeableBlocks = lakhs.ceil();
    final int computed = chargeableBlocks * 150;
    return computed < 250 ? 250 : computed;
  }
}

