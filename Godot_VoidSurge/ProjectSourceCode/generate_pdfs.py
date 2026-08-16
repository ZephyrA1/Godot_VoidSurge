"""Generate GDD.pdf and Postmortem.pdf from project documentation."""
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, HRFlowable
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.lib import colors
import os

OUTPUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "docs")

styles = getSampleStyleSheet()
styles.add(ParagraphStyle("DocTitle", parent=styles["Title"], fontSize=22, spaceAfter=6, textColor=colors.HexColor("#1a1a2e")))
styles.add(ParagraphStyle("SectionHead", parent=styles["Heading2"], fontSize=14, spaceBefore=16, spaceAfter=8, textColor=colors.HexColor("#16213e")))
styles.add(ParagraphStyle("SubHead", parent=styles["Heading3"], fontSize=12, spaceBefore=12, spaceAfter=6))
styles.add(ParagraphStyle("Body", parent=styles["Normal"], fontSize=10, leading=14, spaceAfter=4))
styles.add(ParagraphStyle("Bullet", parent=styles["Normal"], fontSize=10, leading=14, leftIndent=20, bulletIndent=10, spaceAfter=2))
styles.add(ParagraphStyle("TableCell", parent=styles["Normal"], fontSize=9, leading=12))
styles.add(ParagraphStyle("TableHeader", parent=styles["Normal"], fontSize=9, leading=12, textColor=colors.white))


def make_table(headers, rows, col_widths=None):
    data = [[Paragraph("<b>%s</b>" % h, styles["TableHeader"]) for h in headers]]
    for row in rows:
        data.append([Paragraph(str(c), styles["TableCell"]) for c in row])
    t = Table(data, colWidths=col_widths, repeatRows=1)
    t.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#16213e")),
        ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
        ("GRID", (0, 0), (-1, -1), 0.5, colors.grey),
        ("BACKGROUND", (0, 1), (-1, -1), colors.HexColor("#f5f5f5")),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("TOPPADDING", (0, 0), (-1, -1), 4),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
        ("LEFTPADDING", (0, 0), (-1, -1), 6),
        ("RIGHTPADDING", (0, 0), (-1, -1), 6),
    ]))
    return t


def hr():
    return HRFlowable(width="100%", thickness=1, color=colors.HexColor("#cccccc"), spaceAfter=8, spaceBefore=8)


def build_gdd():
    doc = SimpleDocTemplate(
        os.path.join(OUTPUT_DIR, "GDD.pdf"), pagesize=letter,
        leftMargin=0.75 * inch, rightMargin=0.75 * inch,
        topMargin=0.75 * inch, bottomMargin=0.75 * inch,
    )
    s = []

    s.append(Paragraph("Void Surge &mdash; Game Design Document", styles["DocTitle"]))
    s.append(hr())

    # Game Overview
    s.append(Paragraph("Game Overview", styles["SectionHead"]))
    for line in [
        "<b>Title:</b> Void Surge",
        "<b>Genre:</b> Top-down arena survival / roguelite",
        "<b>Engine:</b> Godot 4.6.2 (GDScript)",
        "<b>Platform:</b> Windows (PC), exportable to Mac/Linux",
        "<b>Target Audience:</b> Players who enjoy fast-paced action roguelites (Vampire Survivors, Nuclear Throne, Enter the Gungeon). Casual and mid-core gamers aged 13+.",
        "<b>Session Length:</b> 10&ndash;15 minutes per run",
    ]:
        s.append(Paragraph(line, styles["Bullet"], bulletText="\u2022"))

    s.append(hr())

    # Core Gameplay Loop
    s.append(Paragraph("Core Gameplay Loop", styles["SectionHead"]))
    for i, step in enumerate([
        "<b>Spawn</b> into a contained arena",
        "<b>Survive</b> an enemy wave &mdash; shoot, dodge, and dash to stay alive",
        "<b>Manage heat</b> &mdash; shooting builds heat; high heat boosts damage but overheating burns you and locks your weapon",
        "<b>Clear the wave</b> &mdash; all enemies must be destroyed",
        "<b>Choose an upgrade</b> &mdash; pick 1 of 3 random upgrades to strengthen your build",
        "<b>Repeat</b> &mdash; waves escalate in enemy count, type variety, and stat scaling",
        "<b>Win or die</b> &mdash; survive all 10 waves to win, or die trying",
    ], 1):
        s.append(Paragraph("%d. %s" % (i, step), styles["Body"]))

    s.append(hr())

    # Mechanics
    s.append(Paragraph("Mechanics (MDA &mdash; Mechanics)", styles["SectionHead"]))

    s.append(Paragraph("Controls", styles["SubHead"]))
    s.append(make_table(
        ["Action", "Keyboard/Mouse", "Gamepad"],
        [
            ["Move", "WASD / Arrow Keys", "Left Stick"],
            ["Aim", "Mouse cursor", "Right Stick"],
            ["Shoot", "Left Mouse Button", "RT"],
            ["Dash", "Space / Right Mouse Button", "A / South Button"],
            ["Pause", "Escape", "Start"],
        ],
        col_widths=[1.5 * inch, 2.5 * inch, 2.5 * inch],
    ))
    s.append(Spacer(1, 8))

    s.append(Paragraph("Core Systems", styles["SubHead"]))

    s.append(Paragraph("<b>1. Heat System</b>", styles["Body"]))
    for b in [
        "Every shot adds heat (default 8 per shot, max 100). Heat decays passively (25/sec).",
        "<b>Damage bonus:</b> Bullets deal up to +50% damage at max heat (scales linearly).",
        "<b>Overheat penalty:</b> Reaching 100 heat deals 15 self-damage and locks weapons for 2.5 seconds.",
        "<b>Strategic tension:</b> Players decide whether to run hot for damage or play it cool for safety.",
    ]:
        s.append(Paragraph(b, styles["Bullet"], bulletText="\u2022"))

    s.append(Paragraph("<b>2. Dash System</b>", styles["Body"]))
    for b in [
        "Lunge in movement direction (or toward cursor). Grants i-frames during 0.15s dash.",
        "Cooldown: 1.2s. Passing through enemies deals 30 damage.",
        "Creates a viable melee/dash-focused playstyle as an alternative to pure ranged.",
    ]:
        s.append(Paragraph(b, styles["Bullet"], bulletText="\u2022"))

    s.append(Paragraph("<b>3. Weapon/Shooting</b>", styles["Body"]))
    for b in [
        "Hold shoot for automatic fire. Bullets travel in aimed direction.",
        "<b>Spread shot:</b> Upgrades add projectiles in a fan. <b>Piercing:</b> Bullets pass through enemies.",
    ]:
        s.append(Paragraph(b, styles["Bullet"], bulletText="\u2022"))

    s.append(Paragraph("<b>4. Upgrade System</b>", styles["Body"]))
    for b in [
        "After each wave, 3 random upgrades are presented. 11 total in pool (stackable).",
        "Categories: damage, fire rate, heat management, dash power, survivability, movement.",
    ]:
        s.append(Paragraph(b, styles["Bullet"], bulletText="\u2022"))

    s.append(Paragraph("Core Resources", styles["SubHead"]))
    for b in [
        "<b>Health:</b> Starts at 100. Lost to contact, bullets, overheating. Regen only via upgrades.",
        "<b>Heat:</b> 0&ndash;100 gauge. Rising heat = more damage but risk of overheat.",
        "<b>Dash charge:</b> Binary cooldown; available or recharging.",
    ]:
        s.append(Paragraph(b, styles["Bullet"], bulletText="\u2022"))

    s.append(Paragraph("Progression", styles["SubHead"]))
    for b in [
        "<b>In-run:</b> Upgrade choices between waves (9 upgrades across a full run).",
        "<b>Wave scaling:</b> Enemy health, damage, and variety increase each wave.",
    ]:
        s.append(Paragraph(b, styles["Bullet"], bulletText="\u2022"))

    s.append(hr())

    # Dynamics
    s.append(Paragraph("Dynamics (MDA &mdash; Dynamics)", styles["SectionHead"]))

    s.append(Paragraph("Expected Strategies &amp; Emergent Builds", styles["SubHead"]))
    s.append(make_table(
        ["Build Archetype", "Key Upgrades", "Playstyle"],
        [
            ["Glass Cannon", "Power Shot, Rapid Fire, Pyromaniac", "Max DPS; accept overheat risk; positioning"],
            ["Cold Efficiency", "Coolant System, Piercing, Scatter Cannon", "Sustained fire; crowd control"],
            ["Dash Assassin", "Blade Dash, Quick Step, Thrusters", "Close-range dash damage; weapon secondary"],
            ["Tank", "Reinforced Hull, Auto Repair, Move Speed", "Outlast enemies; absorb hits"],
        ],
        col_widths=[1.5 * inch, 2.5 * inch, 2.5 * inch],
    ))
    s.append(Spacer(1, 6))
    s.append(Paragraph("Most runs will be hybrids &mdash; the randomized pool forces adaptation.", styles["Body"]))

    s.append(Paragraph("Mechanic Interactions", styles["SubHead"]))
    for b in [
        "<b>Heat x Combat:</b> High heat = high reward (damage bonus) but high risk (lockout + self-damage). Constant micro-decision.",
        "<b>Heat x Dash:</b> When overheated, dashing is the only offensive/defensive option. Dash upgrades mitigate overheat punishment.",
        "<b>Upgrades x Enemy Types:</b> Chasers pressure movement; Shooters demand positioning; Dashers require timing.",
        "<b>Spread x Pierce:</b> Combined, they create wide area damage, changing group engagement.",
    ]:
        s.append(Paragraph(b, styles["Bullet"], bulletText="\u2022"))

    s.append(Paragraph("Difficulty Curve", styles["SubHead"]))
    for b in [
        "<b>Waves 1&ndash;3:</b> Chasers only. Teaches movement, shooting, heat awareness.",
        "<b>Waves 4&ndash;6:</b> Shooters added. Forces positioning and dodging while managing heat.",
        "<b>Waves 7&ndash;9:</b> Dashers added. Fast enemies demand dash usage and spatial awareness.",
        "<b>Wave 10:</b> All types, high counts. Tests the full assembled build.",
    ]:
        s.append(Paragraph(b, styles["Bullet"], bulletText="\u2022"))

    s.append(hr())

    # Aesthetics
    s.append(Paragraph("Aesthetics (MDA &mdash; Aesthetics)", styles["SectionHead"]))

    s.append(Paragraph("Intended Feelings", styles["SubHead"]))
    for b in [
        "<b>Challenge:</b> Escalating waves that test mastery of movement and heat management.",
        "<b>Discovery:</b> Each run's random upgrades create a different build and experience.",
        "<b>Sensation:</b> Fast controls with immediate visual feedback (hit flashes, screen shake, particles, color-shifting heat).",
    ]:
        s.append(Paragraph(b, styles["Bullet"], bulletText="\u2022"))

    s.append(Paragraph("Visual Style", styles["SubHead"]))
    for b in [
        "Dark void background with subtle blue tint.",
        "Geometric shapes: triangle (player/chaser), square (shooter), diamond (dasher).",
        "Color-coded: cyan (player), red (chaser), orange (shooter), purple (dasher).",
        "Player body shifts cyan to orange-red with heat. Neon-accented arena border.",
    ]:
        s.append(Paragraph(b, styles["Bullet"], bulletText="\u2022"))

    s.append(hr())

    # Content Plan
    s.append(Paragraph("Content Plan (Final Build)", styles["SectionHead"]))
    s.append(make_table(
        ["Content", "Count", "Details"],
        [
            ["Enemy types", "3", "Chaser, Shooter, Dasher"],
            ["Waves", "10", "Escalating composition and stats"],
            ["Upgrades", "11", "Damage, defense, mobility, heat, utility"],
            ["Screens", "5", "Main menu, HUD, pause, game over, victory"],
            ["Arena", "1", "Fixed-size bordered arena"],
        ],
        col_widths=[2 * inch, 1 * inch, 3.5 * inch],
    ))

    s.append(hr())

    # Implementation Plan
    s.append(Paragraph("Implementation Plan", styles["SectionHead"]))

    s.append(Paragraph("Key Systems", styles["SubHead"]))
    for i, sys in enumerate([
        "<b>GameManager (Autoload):</b> Global state singleton &mdash; score, wave, player stats, upgrade application.",
        "<b>Wave Manager:</b> Spawns enemies per wave definition, tracks remaining, signals wave clear.",
        "<b>Player Controller (CharacterBody2D):</b> Movement, shooting, dash with i-frames, heat, damage feedback.",
        "<b>Enemy Base Class:</b> Shared health/damage/death. Subclasses: Chaser (seek), Shooter (kite+fire), Dasher (circle+charge).",
        "<b>Upgrade Panel (CanvasLayer):</b> Pauses game, presents 3 cards, applies selection to GameManager.",
        "<b>HUD:</b> Real-time bars for health, heat, dash cooldown; wave/score labels; wave banner animation.",
    ], 1):
        s.append(Paragraph("%d. %s" % (i, sys), styles["Body"]))

    s.append(Paragraph("Technical Risks &amp; Mitigations", styles["SubHead"]))
    s.append(make_table(
        ["Risk", "Mitigation"],
        [
            ["Bullet performance with spread + pierce", "Bullets self-destruct on lifetime/distance; object pooling if needed"],
            ["Enemy pathfinding edge cases", "Simple steering behaviors, no navmesh; arena clamping prevents stuck enemies"],
            ["Overheat feels unfair", "Moderate self-damage (15); clear visual warning; lockout tuned to 2.5s"],
            ["Upgrade balance", "Linear stacking with caps; playtested for no trivializing single upgrade"],
        ],
        col_widths=[2.5 * inch, 4 * inch],
    ))

    doc.build(s)
    print("GDD.pdf created successfully")


def build_postmortem():
    doc = SimpleDocTemplate(
        os.path.join(OUTPUT_DIR, "Postmortem.pdf"), pagesize=letter,
        leftMargin=0.75 * inch, rightMargin=0.75 * inch,
        topMargin=0.75 * inch, bottomMargin=0.75 * inch,
    )
    s = []

    s.append(Paragraph("Void Surge &mdash; Postmortem", styles["DocTitle"]))
    s.append(hr())

    s.append(Paragraph("3 Successes", styles["SectionHead"]))

    s.append(Paragraph("1. Heat System Creates Genuine Tension", styles["SubHead"]))
    s.append(Paragraph(
        "The heat mechanic became the defining feature of the game. By tying damage output to heat level, "
        "every moment of combat involves a risk/reward micro-decision: push heat higher for bonus damage, "
        "or ease off to avoid the overheat penalty. This single system connects shooting, dashing, and "
        "upgrade selection into one cohesive loop. Players who get comfortable riding high heat feel rewarded, "
        "while cautious players have a viable path too. The visual feedback &mdash; player color shifting from cyan "
        "to red &mdash; makes the system readable at a glance without needing to stare at the UI bar.",
        styles["Body"],
    ))

    s.append(Paragraph("2. Upgrade Synergies Produce Replayable Runs", styles["SubHead"]))
    s.append(Paragraph(
        "The 11-upgrade pool with random 3-choice presentations creates meaningful variety between runs. "
        "During testing, distinct build archetypes emerged naturally &mdash; glass cannon builds that lean into "
        "Pyromaniac and Rapid Fire feel completely different from Dash Assassin builds stacking Blade Dash "
        "and Quick Step. The key design decision was ensuring upgrades modify existing mechanics rather than "
        "adding new ones, so every choice changes how the player interacts with heat, dashing, or shooting "
        "rather than bolting on disconnected features.",
        styles["Body"],
    ))

    s.append(Paragraph("3. Clean Modular Architecture", styles["SubHead"]))
    s.append(Paragraph(
        "Separating the project into a GameManager autoload, distinct scene-per-entity structure, and a base "
        "enemy class with subclass overrides kept the codebase manageable. Adding a new enemy type or upgrade "
        "is a matter of creating one script and one scene file, then adding an entry to the wave generator or "
        "upgrade pool. The wave manager's signal-based flow (wave_cleared, upgrade_chosen, next wave) kept "
        "the game loop logic in one readable file without spaghetti state.",
        styles["Body"],
    ))

    s.append(hr())

    s.append(Paragraph("3 Challenges", styles["SectionHead"]))

    s.append(Paragraph("1. Balancing Overheat Punishment", styles["SubHead"]))
    s.append(Paragraph(
        "Early iterations made overheating too punishing (instant death) or too lenient (no lockout). "
        "Finding the sweet spot &mdash; 15 self-damage + 2.5 second weapon lockout &mdash; required multiple tuning passes. "
        "The breakthrough was realizing that the lockout must be survivable if the player has dash available, "
        "which naturally reinforces the Heat x Dash interaction. We also added the escalating visual warning "
        "(color shift + OVERHEATED text) so players never feel blindsided.",
        styles["Body"],
    ))

    s.append(Paragraph("2. Enemy Spawn Pacing", styles["SubHead"]))
    s.append(Paragraph(
        "Initially all wave enemies spawned simultaneously, which caused difficulty spikes and frame drops on "
        "larger waves. The fix was staggering spawns with a 0.4-second interval, which spreads enemies around "
        "the arena edges and gives players a few moments to react. Wave 10 (final wave) was especially tricky &mdash; "
        "it needed to feel climactic without being unfair. The solution was higher enemy counts with the same "
        "stat scaling, so it tests the player's build rather than just overwhelming them.",
        styles["Body"],
    ))

    s.append(Paragraph("3. Scene File Complexity in Godot", styles["SubHead"]))
    s.append(Paragraph(
        "Building UI-heavy scenes (HUD with multiple progress bars, upgrade panel with dynamic card generation) "
        "required careful node hierarchy management. Godot's .tscn format is powerful but verbose for complex UIs. "
        "We addressed this by keeping .tscn files minimal (structural nodes only) and building dynamic content in "
        "code &mdash; the upgrade cards, for example, are entirely code-generated, which made them easier to iterate on "
        "than editing deeply nested scene trees.",
        styles["Body"],
    ))

    s.append(hr())

    s.append(Paragraph("If We Had 2 More Weeks...", styles["SectionHead"]))

    s.append(Paragraph("1. Audio System", styles["SubHead"]))
    s.append(Paragraph(
        "Procedurally generated sound effects (shooting, dash whoosh, enemy death, overheat alarm) using Godot's "
        "AudioStreamGenerator. The game currently relies on strong visual feedback, but audio would significantly "
        "enhance the sensation aesthetic &mdash; especially a rising hum as heat climbs.",
        styles["Body"],
    ))

    s.append(Paragraph("2. Between-Run Meta-Progression", styles["SubHead"]))
    s.append(Paragraph(
        "A persistent unlock system where completing runs (or reaching certain waves) unlocks new starting loadouts "
        "or bonus upgrade pool entries. This would add long-term replayability beyond the single-run upgrade variety "
        "and give players goals across multiple sessions.",
        styles["Body"],
    ))

    doc.build(s)
    print("Postmortem.pdf created successfully")


if __name__ == "__main__":
    build_gdd()
    build_postmortem()
