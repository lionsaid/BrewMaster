import 'package:brew_master/core/services/brew_service.dart';
import 'package:brew_master/core/widgets/app_card.dart';
import 'package:brew_master/core/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:brew_master/l10n/app_localizations.dart';

class TapsView extends StatefulWidget {
  const TapsView({super.key});

  @override
  State<TapsView> createState() => _TapsViewState();
}

class _TapsViewState extends State<TapsView> {
  final BrewService _brew = BrewService();
  bool _loading = true;
  List<String> _taps = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _brew.listTaps();
      setState(() => _taps = list);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(AppLocalizations.of(context)!.tapsTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const Spacer(),
                          ActionButton(
                onPressed: _loading ? null : _load, 
                isPrimary: true,
                minWidth: 80,
                child: Text(AppLocalizations.of(context)!.actionRefresh),
              ),
          ]),
          const SizedBox(height: 16),
          Expanded(
            child: FrostCard(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : (_taps.isEmpty
                      ? Center(child: Text(AppLocalizations.of(context)!.tapsEmpty))
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: _taps.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (_, i) => ListTile(
                            leading: const Icon(Icons.merge_type_outlined),
                            title: Text(_taps[i]),
                          ),
                        )),
            ),
          ),
        ],
      ),
    );
  }
}
