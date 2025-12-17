pragma Singleton
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    /**
     * Get stretch transform for condensed/tall effect
     * @param {number} horizontal - Width scale (0.6 = 60% width for condensed)
     * @param {number} vertical - Height scale (1.0 = normal height)
     */
    function getStretch(horizontal = 0.6, vertical = 1.0) {
        return [
            {
                type: "scale",
                xScale: horizontal,
                yScale: vertical
            }
        ];
    }
}
