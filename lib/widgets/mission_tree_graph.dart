import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../models/mission.dart';
import '../theme/app_theme.dart';

class MissionTreeGraph extends StatelessWidget {
  const MissionTreeGraph({
    required this.missions,
    required this.selectedMissionId,
    required this.onSelectMission,
    super.key,
  });

  final List<Mission> missions;
  final String? selectedMissionId;
  final ValueChanged<Mission> onSelectMission;

  @override
  Widget build(BuildContext context) {
    final _TreeLayout layout = _TreeLayout.fromMissions(missions);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 860;

        final Widget graphSurface = SizedBox(
          width: math.max(layout.canvasSize.width, constraints.maxWidth - 8),
          height: math.max(layout.canvasSize.height, constraints.maxHeight - 8),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: CustomPaint(
                  painter: MissionConnectionPainter(layout: layout),
                ),
              ),
              ...layout.eraLabels.map(
                (_EraLabelData label) => Positioned(
                  key: ValueKey<String>('era-${label.text}-${label.level}'),
                  left: 16,
                  top: label.y,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.panel.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(AppRadius.circle),
                      border: Border.all(color: AppColors.panelBorder),
                    ),
                    child: Text(
                      label.text,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ),
              ...layout.nodes.map(
                (_NodeLayout node) => Positioned(
                  key: ValueKey<String>('graph-node-${node.mission.id}'),
                  left: node.center.dx - (_MissionNodeCircle.diameter / 2),
                  top: node.center.dy - (_MissionNodeCircle.diameter / 2),
                  child: _MissionNodeCircle(
                    mission: node.mission,
                    selected: selectedMissionId == node.mission.id,
                    onTap: () => onSelectMission(node.mission),
                  ),
                ),
              ),
            ],
          ),
        );

        if (!compact) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(child: graphSurface),
            ),
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: InteractiveViewer(
            minScale: 0.82,
            maxScale: 1.65,
            constrained: false,
            child: graphSurface,
          ),
        );
      },
    );
  }
}

class MissionConnectionPainter extends CustomPainter {
  MissionConnectionPainter({required this.layout});

  final _TreeLayout layout;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint solid = Paint()
      ..color = AppColors.panelBorder
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final Paint dashed = Paint()
      ..color = AppColors.textMuted.withOpacity(0.7)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    for (final _Connection c in layout.connections) {
      final bool useDashed = c.child.status == MissionStatus.locked;
      final Paint p = useDashed ? dashed : solid;
      final Path path = Path()
        ..moveTo(c.from.dx, c.from.dy)
        ..cubicTo(c.from.dx, c.from.dy + 42, c.to.dx, c.to.dy - 42, c.to.dx, c.to.dy);

      if (useDashed) {
        _drawDashedPath(canvas, path, p);
      } else {
        canvas.drawPath(path, p);
      }
    }
  }

  void _drawDashedPath(Canvas canvas, Path source, Paint paint) {
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0;
      const double dash = 8;
      const double gap = 6;
      while (distance < metric.length) {
        final double next = math.min(distance + dash, metric.length);
        final Path segment = metric.extractPath(distance, next);
        canvas.drawPath(segment, paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant MissionConnectionPainter oldDelegate) {
    return oldDelegate.layout != layout;
  }
}

class _MissionNodeCircle extends StatelessWidget {
  const _MissionNodeCircle({
    required this.mission,
    required this.selected,
    required this.onTap,
  });

  static const double diameter = 92;

  final Mission mission;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _statusColor(mission.status);
    final bool pulse = mission.status == MissionStatus.inProgress;

    return Semantics(
      button: true,
      label: mission.name,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.panelLight,
            border: Border.all(
              color: selected ? statusColor : statusColor.withOpacity(0.78),
              width: selected ? 3 : 2,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: statusColor.withOpacity(selected ? 0.28 : 0.14),
                blurRadius: selected ? 16 : 9,
                spreadRadius: pulse ? 2 : 0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(_missionIcon(mission), size: 20, color: statusColor),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  _shortLabel(mission.name),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                mission.year.toString(),
                style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _shortLabel(String name) {
    final List<String> parts = name.split(' ');
    if (parts.length <= 2) {
      return name;
    }
    return '${parts.first} ${parts[1]}';
  }

  IconData _missionIcon(Mission mission) {
    final String t = mission.type.toLowerCase();
    if (t.contains('orbita') || t.contains('orbital')) {
      return Icons.travel_explore_outlined;
    }
    if (t.contains('luna')) {
      return Icons.dark_mode_outlined;
    }
    if (t.contains('mars') || t.contains('marte')) {
      return Icons.public_outlined;
    }
    if (t.contains('satelite')) {
      return Icons.satellite_alt_outlined;
    }
    return Icons.rocket_launch_outlined;
  }

  Color _statusColor(MissionStatus status) {
    return switch (status) {
      MissionStatus.available => AppColors.available,
      MissionStatus.success => AppColors.success,
      MissionStatus.partialSuccess => AppColors.yellow,
      MissionStatus.failure => AppColors.red,
      MissionStatus.inProgress => AppColors.accent,
      MissionStatus.locked => AppColors.locked,
    };
  }
}

class _TreeLayout {
  _TreeLayout({
    required this.nodes,
    required this.connections,
    required this.canvasSize,
    required this.eraLabels,
  });

  final List<_NodeLayout> nodes;
  final List<_Connection> connections;
  final Size canvasSize;
  final List<_EraLabelData> eraLabels;

  static _TreeLayout fromMissions(List<Mission> missions) {
    if (missions.isEmpty) {
      return _TreeLayout(
        nodes: const <_NodeLayout>[],
        connections: const <_Connection>[],
        canvasSize: const Size(500, 500),
        eraLabels: const <_EraLabelData>[],
      );
    }

    final Map<String, Mission> byId = <String, Mission>{
      for (final Mission m in missions) m.id: m,
    };
    final Map<String, int> levels = <String, int>{};

    int depthOf(Mission mission) {
      final int? cached = levels[mission.id];
      if (cached != null) {
        return cached;
      }
      if (mission.requiredMissions.isEmpty) {
        levels[mission.id] = 0;
        return 0;
      }
      final int d = mission.requiredMissions
          .map((String parentId) => byId[parentId])
          .whereType<Mission>()
          .map((Mission parent) => depthOf(parent) + 1)
          .fold<int>(0, math.max);
      levels[mission.id] = d;
      return d;
    }

    for (final Mission m in missions) {
      depthOf(m);
    }

    final Map<int, List<Mission>> levelGroups = <int, List<Mission>>{};
    for (final Mission m in missions) {
      final int level = levels[m.id] ?? 0;
      levelGroups.putIfAbsent(level, () => <Mission>[]).add(m);
    }

    for (final List<Mission> list in levelGroups.values) {
      list.sort((Mission a, Mission b) {
        final int y = a.year.compareTo(b.year);
        if (y != 0) {
          return y;
        }
        return a.name.compareTo(b.name);
      });
    }

    const double nodeD = _MissionNodeCircle.diameter;
    const double colGap = 168;
    const double rowGap = 176;
    const double padX = 100;
    const double padY = 92;

    final int maxColumns = levelGroups.values.fold<int>(1, (int p, List<Mission> l) => math.max(p, l.length));
    final int maxLevel = levelGroups.keys.fold<int>(0, math.max);

    final double width = (maxColumns <= 1)
        ? 420
        : (padX * 2) + ((maxColumns - 1) * colGap) + nodeD;
    final double height = (padY * 2) + (maxLevel * rowGap) + nodeD;

    final Map<String, Offset> centersById = <String, Offset>{};
    final List<_NodeLayout> nodes = <_NodeLayout>[];
    final List<_EraLabelData> labels = <_EraLabelData>[];

    final List<int> sortedLevels = levelGroups.keys.toList()..sort();
    for (final int level in sortedLevels) {
      final List<Mission> list = levelGroups[level]!;
      final double levelWidth = (list.length - 1) * colGap;
      final double startX = (width / 2) - (levelWidth / 2);
      final double y = padY + (level * rowGap);

      final Mission first = list.first;
      final Mission last = list.last;
      labels.add(_EraLabelData(
        level: level,
        text: '${first.era} (${first.year}-${last.year})',
        y: y - 54,
      ));

      for (int i = 0; i < list.length; i++) {
        final Mission m = list[i];
        final Offset c = Offset(startX + (i * colGap) + (nodeD / 2), y + (nodeD / 2));
        centersById[m.id] = c;
        nodes.add(_NodeLayout(mission: m, center: c, level: level, column: i));
      }
    }

    final List<_Connection> connections = <_Connection>[];
    for (final Mission mission in missions) {
      final Offset? toCenter = centersById[mission.id];
      if (toCenter == null) {
        continue;
      }
      for (final String parentId in mission.requiredMissions) {
        final Offset? parentCenter = centersById[parentId];
        if (parentCenter == null) {
          continue;
        }
        connections.add(_Connection(
          from: Offset(parentCenter.dx, parentCenter.dy + (nodeD / 2) - 2),
          to: Offset(toCenter.dx, toCenter.dy - (nodeD / 2) + 2),
          child: mission,
        ));
      }
    }

    return _TreeLayout(
      nodes: nodes,
      connections: connections,
      canvasSize: Size(width, height),
      eraLabels: labels,
    );
  }
}

class _NodeLayout {
  _NodeLayout({
    required this.mission,
    required this.center,
    required this.level,
    required this.column,
  });

  final Mission mission;
  final Offset center;
  final int level;
  final int column;
}

class _Connection {
  _Connection({
    required this.from,
    required this.to,
    required this.child,
  });

  final Offset from;
  final Offset to;
  final Mission child;
}

class _EraLabelData {
  _EraLabelData({required this.level, required this.text, required this.y});

  final int level;
  final String text;
  final double y;
}
