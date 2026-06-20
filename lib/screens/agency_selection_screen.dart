import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../audio/audio_manager.dart';
import '../audio/sound_effect.dart';
import '../game/game_controller.dart';
import '../models/agency.dart';
import '../widgets/control_card.dart';
import '../widgets/reputation_bar.dart';
import 'campaign_hub_screen.dart';

class AgencySelectionScreen extends StatefulWidget {
  const AgencySelectionScreen({
    required this.controller,
    super.key,
  });

  final GameController controller;

  @override
  State<AgencySelectionScreen> createState() => _AgencySelectionScreenState();
}

class _AgencySelectionScreenState extends State<AgencySelectionScreen> {
  String? _hoveredAgencyId;

  bool get _supportsHover {
    if (kIsWeb) {
      return true;
    }
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  void _handleAgencyHoverEnter(Agency agency) {
    if (_hoveredAgencyId == agency.id) {
      return;
    }
    setState(() => _hoveredAgencyId = agency.id);
    AudioManager.instance.playAgencyHover(agency);
  }

  void _handleAgencyHoverExit(Agency agency) {
    if (_hoveredAgencyId != agency.id) {
      return;
    }
    setState(() => _hoveredAgencyId = null);
    AudioManager.instance.stopAgencyHover();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioManager.instance.startBackgroundMusic(SoundEffect.menuAmbient);
    });
  }

  @override
  Widget build(BuildContext context) {
    final GameController controller = widget.controller;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecione sua Agencia'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            AudioManager.instance.playUi(SoundEffect.uiBack);
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: controller.agencies.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (BuildContext context, int index) {
          final Agency agency = controller.agencies[index];
          final bool hovered = _hoveredAgencyId == agency.id;
          return MouseRegion(
            onEnter: (_) => _handleAgencyHoverEnter(agency),
            onExit: (_) => _handleAgencyHoverExit(agency),
            child: AnimatedContainer(
              key: ValueKey<String>('agency-card-${agency.id}'),
              duration: const Duration(milliseconds: 170),
              curve: Curves.easeOut,
              transform: Matrix4.identity()
                ..translate(0.0, hovered ? -2.0 : 0.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hovered
                      ? Colors.cyanAccent.withOpacity(0.42)
                      : Colors.transparent,
                  width: hovered ? 1.2 : 1,
                ),
                boxShadow: hovered
                    ? <BoxShadow>[
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.14),
                          blurRadius: 18,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: ControlCard(
                accentColor: hovered ? Colors.cyanAccent : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            agency.name,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Chip(label: Text(agency.country)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(agency.description),
                    const SizedBox(height: 10),
                    ReputationBar(value: agency.initialReputation),
                    const SizedBox(height: 10),
                    Text('Orcamento Base: ${agency.baseBudget}M'),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          if (!_supportsHover) {
                            AudioManager.instance.playAgencyHover(agency);
                          }
                          AudioManager.instance.playAgencySelection(agency);
                          AudioManager.instance.playUi(SoundEffect.uiConfirm);
                          controller.selectAgency(agency);
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  CampaignHubScreen(controller: controller),
                            ),
                          );
                        },
                        child: const Text('Escolher Agencia'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
