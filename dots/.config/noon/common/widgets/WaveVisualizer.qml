import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import qs.common
import qs.common.widgets
import qs.services

Canvas {
    id: root

    property list<var> points
    property real maxVisualizerValue: 1000
    property bool live: true
    property color color: Colors.m3.m3primary
    property string visualizerType: "filled"

    // Visual properties
    property real barSpacing: 2
    property real thickBarSpacing: 4
    property real thickBarCornerRadius: 6
    property real animationTime: 0

    anchors.fill: parent

    // Trigger repaint when points change
    onPointsChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);

        if (!root.live || points.length < 2) {
            return;
        }

        var w = width;
        var h = height;
        var n = points.length;
        var maxVal = maxVisualizerValue;

        // Draw based on type
        switch (visualizerType) {
        case "bars":
            drawBars(ctx, w, h, n, maxVal);
            break;
        case "thickbars":
            drawThickBars(ctx, w, h, n, maxVal);
            break;
        case "waveform":
            drawWaveform(ctx, w, h, n, maxVal);
            break;
        case "circular":
            drawCircular(ctx, w, h, n, maxVal);
            break;
        case "atom":
            drawAtom(ctx, w, h, n, maxVal);
            break;
        default:
            drawFilled(ctx, w, h, n, maxVal);
        }
    }

    function drawFilled(ctx, w, h, n, maxVal) {
        ctx.beginPath();
        ctx.moveTo(0, h);
        for (var i = 0; i < n; ++i) {
            var x = i * w / (n - 1);
            var y = h - (points[i] / maxVal) * h;
            ctx.lineTo(x, y);
        }
        ctx.lineTo(w, h);
        ctx.closePath();
        ctx.fillStyle = Qt.rgba(color.r, color.g, color.b, 0.15);
        ctx.fill();
    }

    function drawBars(ctx, w, h, n, maxVal) {
        var barWidth = (w - (n - 1) * barSpacing) / n;
        ctx.fillStyle = Qt.rgba(color.r, color.g, color.b, 0.8);
        for (var i = 0; i < n; ++i) {
            var x = i * (barWidth + barSpacing);
            var barHeight = (points[i] / maxVal) * h;
            var y = h - barHeight;
            ctx.fillRect(x, y, barWidth, barHeight);
        }
    }

    function drawThickBars(ctx, w, h, n, maxVal) {
        var barWidth = (w - (n - 1) * thickBarSpacing) / n;
        var cornerRadius = Math.min(thickBarCornerRadius, barWidth / 2);

        for (var i = 0; i < n; ++i) {
            var x = i * (barWidth + thickBarSpacing);
            var barHeight = Math.max(cornerRadius * 2, (points[i] / maxVal) * h);
            var y = h - barHeight;

            ctx.beginPath();
            ctx.moveTo(x, h);
            ctx.lineTo(x, y + cornerRadius);
            ctx.quadraticCurveTo(x, y, x + cornerRadius, y);
            ctx.lineTo(x + barWidth - cornerRadius, y);
            ctx.quadraticCurveTo(x + barWidth, y, x + barWidth, y + cornerRadius);
            ctx.lineTo(x + barWidth, h);
            ctx.closePath();

            var gradient = ctx.createLinearGradient(x, y, x + barWidth, y);
            gradient.addColorStop(0, Qt.rgba(color.r, color.g, color.b, 0.9));
            gradient.addColorStop(0.5, Qt.rgba(color.r, color.g, color.b, 1));
            gradient.addColorStop(1, Qt.rgba(color.r, color.g, color.b, 0.9));
            ctx.fillStyle = gradient;
            ctx.fill();
        }
    }

    function drawWaveform(ctx, w, h, n, maxVal) {
        var centerY = h / 2;

        // Top half
        ctx.beginPath();
        ctx.moveTo(0, centerY);
        for (var i = 0; i < n; ++i) {
            var x = i * w / (n - 1);
            var amplitude = (points[i] / maxVal) * (centerY * 0.8);
            ctx.lineTo(x, centerY - amplitude);
        }
        ctx.lineTo(w, centerY);
        ctx.closePath();
        ctx.fillStyle = Qt.rgba(color.r, color.g, color.b, 0.6);
        ctx.fill();

        // Bottom reflection
        ctx.beginPath();
        ctx.moveTo(0, centerY);
        for (var i = 0; i < n; ++i) {
            var x = i * w / (n - 1);
            var amplitude = (points[i] / maxVal) * (centerY * 0.8);
            ctx.lineTo(x, centerY + amplitude);
        }
        ctx.lineTo(w, centerY);
        ctx.closePath();
        ctx.fillStyle = Qt.rgba(color.r, color.g, color.b, 0.2);
        ctx.fill();
    }

    function drawCircular(ctx, w, h, n, maxVal) {
        var centerX = w / 2;
        var centerY = h / 2;
        var innerRadius = Math.min(w, h) * 0.2;
        var outerRadius = Math.min(w, h) * 0.4;

        ctx.beginPath();
        for (var i = 0; i < n; ++i) {
            var angle = (i / n) * 2 * Math.PI;
            var amplitude = (points[i] / maxVal) * (outerRadius - innerRadius);
            var radius = innerRadius + amplitude;
            var x = centerX + radius * Math.cos(angle);
            var y = centerY + radius * Math.sin(angle);

            if (i === 0)
                ctx.moveTo(x, y);
            else
                ctx.lineTo(x, y);
        }
        ctx.closePath();
        ctx.fillStyle = Qt.rgba(color.r, color.g, color.b, 0.3);
        ctx.fill();
        ctx.strokeStyle = Qt.rgba(color.r, color.g, color.b, 0.8);
        ctx.lineWidth = 2;
        ctx.stroke();
    }

    function drawAtom(ctx, w, h, n, maxVal) {
        var centerX = w / 2;
        var centerY = h / 2;
        var baseRadius = Math.min(w, h) * 0.15;

        // Calculate energy from average
        var avgAmplitude = 0;
        for (var i = 0; i < n; ++i)
            avgAmplitude += points[i];
        avgAmplitude /= n;
        var energy = avgAmplitude / maxVal;

        var mainRadius = baseRadius + energy * 30;

        // Draw energy rings
        var ringCount = 3;
        for (var ring = 0; ring < ringCount; ++ring) {
            var ringRadius = mainRadius + ring * 20;
            var ringAlpha = (1 - ring / ringCount) * energy * 0.6;

            ctx.beginPath();
            var segments = 32;
            for (var i = 0; i <= segments; ++i) {
                var angle = (i / segments) * 2 * Math.PI;
                var wave = Math.sin(angle * 3 + animationTime * 2) * 8;

                var audioIndex = Math.floor((i / segments) * n);
                var audioInfluence = (points[audioIndex] / maxVal) * 15;

                var radius = ringRadius + wave + audioInfluence;
                var x = centerX + radius * Math.cos(angle);
                var y = centerY + radius * Math.sin(angle);

                if (i === 0)
                    ctx.moveTo(x, y);
                else
                    ctx.lineTo(x, y);
            }
            ctx.closePath();

            var gradient = ctx.createRadialGradient(centerX, centerY, 0, centerX, centerY, ringRadius * 2);
            gradient.addColorStop(0, Qt.rgba(color.r, color.g, color.b, ringAlpha));
            gradient.addColorStop(1, Qt.rgba(color.r, color.g, color.b, 0));
            ctx.fillStyle = gradient;
            ctx.fill();
        }

        // Core
        var coreRadius = baseRadius * 0.6 + energy * 20;
        var coreGradient = ctx.createRadialGradient(centerX, centerY, 0, centerX, centerY, coreRadius);
        coreGradient.addColorStop(0, Qt.rgba(color.r, color.g, color.b, 0.9));
        coreGradient.addColorStop(1, Qt.rgba(color.r, color.g, color.b, 0));
        ctx.beginPath();
        ctx.arc(centerX, centerY, coreRadius, 0, 2 * Math.PI);
        ctx.fillStyle = coreGradient;
        ctx.fill();
    }

    Timer {
        interval: 16
        running: root.live
        repeat: true
        onTriggered: {
            root.animationTime += 0.05;
            root.requestPaint();
        }
    }
}
