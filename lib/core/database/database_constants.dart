class DatabaseConstants {
  DatabaseConstants._();

  static const databaseName = 'shop.db';
  static const databaseVersion = 2;

  static const categoryTable = 'Category';
  static const productTable = 'Product';
  static const paymentTable = 'Payment';
  static const paymentDetailTable = 'PaymentDetail';

  static const id = 'id';
  static const name = 'name';
  static const image = 'image';
  static const price = 'price';
  static const description = 'description';
  static const categoryId = 'categoryId';
  static const categoryName = 'categoryName';

  static const totalAmount = 'totalAmount';
  static const paymentMethod = 'paymentMethod';
  static const status = 'status';
  static const customerId = 'customerId';
  static const customerName = 'customerName';
  static const note = 'note';
  static const createdAt = 'createdAt';
  static const itemCount = 'itemCount';

  static const paymentId = 'paymentId';
  static const productSource = 'productSource';
  static const productId = 'productId';
  static const productName = 'productName';
  static const productImage = 'productImage';
  static const quantity = 'quantity';
  static const unitPrice = 'unitPrice';
  static const subtotal = 'subtotal';

  static const productCategoryIndex = 'idx_product_category';
  static const paymentCreatedAtIndex = 'idx_payment_created_at';
  static const paymentDetailPaymentIndex = 'idx_payment_detail_payment';

  static const paymentStatusCompleted = 'completed';
  static const paymentStatusPending = 'pending';
  static const paymentMethodCash = 'cash';
  static const productSourceSqlite = 'sqlite';
  static const productSourceHive = 'hive';
  static const productSourceApi = 'api';
  static const productSourceFirebase = 'firebase';
}
