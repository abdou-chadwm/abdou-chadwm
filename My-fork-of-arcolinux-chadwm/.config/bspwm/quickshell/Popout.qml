import QtQuick
import Quickshell

// Shared shell for every bar popup: a fullscreen transparent catcher
// window with the styled card anchored under its bar item. Clicking
// anywhere outside the card closes it; Escape too (when X grants the
// popup key focus). All popups use this, so chrome and behavior stay
// identical.
// Without a compositor the "transparent" catcher would render opaque
// black — blacking out the whole screen — so when picom isn't running
// (Sys.composited) the window degrades to card-only: same card, same
// spot, no catcher. Click-outside close is lost in that mode; Escape
// and the module's own toggle still close.
// Multi-monitor: the catcher covers the output whose bar owns the anchor
// item, and all offsets are relative to that output, not the X root.
PopupWindow {
    id: root

    property Item anchorItem
    property real cardWidth: 300
    property real cardHeight: 300
    readonly property real cardPadding: 14
    // right-edge panel mode (control center) instead of centered-under-anchor
    property bool alignRight: false

    readonly property bool catcher: Sys.composited

    default property alias content: inner.data

    // the output whose bar owns the anchor item (falls back to the first)
    readonly property var barScreen: anchorItem?.QsWindow?.window?.screen
        ?? (Quickshell.screens.length ? Quickshell.screens[0] : null)
    readonly property real screenX: barScreen?.x ?? 0
    readonly property real screenY: barScreen?.y ?? 0
    readonly property real screenW: barScreen?.width ?? 1920
    readonly property real screenH: barScreen?.height ?? 1080

    visible: false
    color: "transparent"

    anchor.item: anchorItem
    // catcher mode: stretch the window over the whole screen so outside
    // clicks land on it; card-only mode: the window IS the card
    anchor.rect.x: catcher ? (anchorItem ? screenX - anchorItem.mapToGlobal(0, 0).x : 0)
                           : uOffsetX
    anchor.rect.y: catcher ? (anchorItem ? screenY - anchorItem.mapToGlobal(0, 0).y : 0)
                           : (anchorItem?.height ?? 0) + 12
    implicitWidth: catcher ? screenW : cardWidth
    implicitHeight: catcher ? screenH : cardHeight

    // anchor's position on its output, captured at open time — mapToGlobal
    // in a static binding evaluates before the item is mapped and returns 0
    property real ax: 0
    property real ay: 0
    // card-only mode: window x offset from the anchor item, clamped to
    // the screen like the catcher-mode card
    property real uOffsetX: 0

    onVisibleChanged: {
        if (visible && anchorItem) {
            const p = anchorItem.mapToGlobal(0, 0)
            ax = p.x - screenX
            ay = p.y - screenY
            const sw = screenW
            const desired = alignRight ? sw - cardWidth - 8
                : Math.min(Math.max(ax + anchorItem.width / 2 - cardWidth / 2, 8),
                           sw - cardWidth - 8)
            uOffsetX = desired - ax
            inner.forceActiveFocus()
            enterAnim.restart()
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.visible = false
    }

    Rectangle {
        id: card

        x: !root.catcher ? 0
         : root.alignRight ? root.width - width - 8
         : Math.min(Math.max(root.ax + (root.anchorItem?.width ?? 0) / 2 - width / 2, 8),
                    root.width - width - 8)
        y: root.catcher ? root.ay + (root.anchorItem?.height ?? 0) + 12 : 0

        transform: Translate { id: slide; y: 0 }

        ParallelAnimation {
            id: enterAnim
            NumberAnimation { target: slide; property: "y"; from: -10; to: 0
                              duration: 160; easing.type: Easing.OutCubic }
            NumberAnimation { target: card; property: "opacity"; from: 0; to: 1
                              duration: 160 }
        }
        width: root.cardWidth
        height: root.cardHeight
        radius: 12
        color: Theme.bg
        border.width: 1
        border.color: Qt.alpha(Theme.accent, 0.4)

        Behavior on color { ColorAnimation { duration: 250 } }

        // swallow card clicks so they don't fall through to the catcher
        MouseArea { anchors.fill: parent }

        Item {
            id: inner
            anchors.fill: parent
            anchors.margins: root.cardPadding
            focus: true
            Keys.onEscapePressed: root.visible = false
        }
    }
}
