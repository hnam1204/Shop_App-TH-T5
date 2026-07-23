import 'package:flutter/material.dart';

import '../models/login_history_model.dart';
import '../services/local_storage_service.dart';
import '../widgets/app_state_widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<LoginHistoryModel> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    final history = await LocalStorageService.getLoginHistory();
    if (!mounted) return;

    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  Future<void> _confirmClearHistory() async {
    if (_history.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('X\u00f3a l\u1ecbch s\u1eed'),
          content: const Text(
            'B\u1ea1n c\u00f3 ch\u1eafc mu\u1ed1n x\u00f3a to\u00e0n b\u1ed9 l\u1ecbch s\u1eed \u0111\u0103ng nh\u1eadp kh\u00f4ng?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('H\u1ee7y'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('X\u00f3a'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await LocalStorageService.clearLoginHistory();
    if (!mounted) return;
    await _loadHistory();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '\u0110\u00e3 x\u00f3a l\u1ecbch s\u1eed \u0111\u0103ng nh\u1eadp',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showHistoryDetail(BuildContext context, LoginHistoryModel item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chi ti\u1ebft \u0111\u0103ng nh\u1eadp'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: ${item.email}'),
              const SizedBox(height: 8),
              Text('Th\u1eddi gian: ${item.loginTime}'),
              const SizedBox(height: 8),
              Text('L\u1ea7n \u0111\u0103ng nh\u1eadp: ${item.title}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('\u0110\u00f3ng'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      child: Column(
        children: [
          _HistoryHeader(onClear: _confirmClearHistory),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingState(message: 'Đang tải lịch sử...');
    }

    if (_history.isEmpty) {
      return const EmptyState(
        icon: Icons.history_rounded,
        message: 'Chưa có lịch sử đăng nhập',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final item = _history[index];
          return _HistoryItem(
            history: item,
            onTap: () => _showHistoryDetail(context, item),
          );
        },
      ),
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  final VoidCallback onClear;

  const _HistoryHeader({required this.onClear});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.24),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Lịch sử đăng nhập',
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Xóa lịch sử',
            onPressed: onClear,
            icon: Icon(
              Icons.delete_outline_rounded,
              color: colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final LoginHistoryModel history;
  final VoidCallback onTap;

  const _HistoryItem({required this.history, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.history_rounded,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              history.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              history.loginTime,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        history.title,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Xem chi tiết',
                  onPressed: onTap,
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
