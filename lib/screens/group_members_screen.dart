import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/group.dart';
import '../models/group_member.dart';
import '../providers/app_state.dart';

class GroupMembersScreen extends StatefulWidget {
  const GroupMembersScreen({super.key});

  @override
  State<GroupMembersScreen> createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends State<GroupMembersScreen> {
  GroupModel? _group;
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requested) {
      return;
    }
    _requested = true;
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is GroupModel) {
      _group = arg;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AppState>().loadGroupMembers(groupId: arg.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final members = state.currentGroupMembers;

    return Scaffold(
      appBar: AppBar(
        title: Text(_group?.name ?? 'Group Members'),
        backgroundColor: Colors.red,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFECEC), Colors.white],
          ),
        ),
        child: _buildBody(state, members),
      ),
    );
  }

  Widget _buildBody(AppState state, List<GroupMember> members) {
    if (state.isGroupMembersLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (members.isEmpty) {
      return const Center(child: Text('No members found for this group'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(14),
      itemCount: members.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final member = members[i];
        return _MemberCard(
          name: member.name.isEmpty ? 'Unnamed Member' : member.name,
          location: member.cityId.isEmpty ? 'N/A' : 'City ID: ${member.cityId}',
          phone: member.phone.isEmpty ? 'N/A' : member.phone,
        );
      },
    );
  }
}

class _MemberCard extends StatefulWidget {
  final String name;
  final String location;
  final String phone;

  const _MemberCard({
    required this.name,
    required this.location,
    required this.phone,
  });

  @override
  State<_MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends State<_MemberCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 180),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFE63946);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_controller.value);
        final lift = 4.0 * t;
        final scale = 1.0 - (0.012 * t);
        return Transform.translate(
          offset: Offset(0, -lift),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFFFFF), Color(0xFFF7F9FC)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: Colors.white, width: 1.2),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -20,
                right: -12,
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.10),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accent.withValues(alpha: 0.22),
                          accent.withValues(alpha: 0.08),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Color(0xFFB91C1C),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.phone,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ActionButton(
                        icon: Icons.call_rounded,
                        color: const Color(0xFF16A34A),
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Call tapped')),
                        ),
                      ),
                      const SizedBox(height: 6),
                      _ActionButton(
                        icon: Icons.message_rounded,
                        color: const Color(0xFF0F766E),
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('WhatsApp tapped')),
                        ),
                      ),
                      const SizedBox(height: 6),
                      _ActionButton(
                        icon: Icons.location_on_rounded,
                        color: const Color(0xFFDC2626),
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Location tapped')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 17, color: color),
      ),
    );
  }
}
