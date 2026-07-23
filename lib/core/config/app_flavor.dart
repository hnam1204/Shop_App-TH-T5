enum AppFlavor { demo, store }

abstract final class AppFlavorConfig {
  static const _value = String.fromEnvironment(
    'APP_FLAVOR',
    defaultValue: 'demo',
  );

  static const current = _value == 'store' ? AppFlavor.store : AppFlavor.demo;

  static const isStore = current == AppFlavor.store;
  static const isDemo = current == AppFlavor.demo;
}

abstract final class AppBrand {
  static const name = 'Shop App';
  static const shortName = 'Shop';
  static const tagline = 'Mua sắm dễ dàng, mỗi ngày';
}
