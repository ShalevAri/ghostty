#version 330 core

in vec2 glyph_tex_coords;
flat in uint mode;

// The color for this cell. If this is a background pass this is the
// background color. Otherwise, this is the foreground color.
flat in vec4 color;

// The position of the cells top-left corner.
flat in vec2 screen_cell_pos;

// Position the fragment coordinate to the upper left
layout(origin_upper_left) in vec4 gl_FragCoord;

// Must declare this output for some versions of OpenGL.
layout(location = 0) out vec4 FragColor;

// Font texture
uniform sampler2D text;

// Dimensions of the cell
uniform vec2 cell_size;

// See fragment shader
const uint MODE_BG = 1u;
const uint MODE_FG = 2u;
const uint MODE_CURSOR_RECT = 3u;
const uint MODE_CURSOR_RECT_HOLLOW = 4u;

void main() {
    switch (mode) {
    case MODE_BG:
        FragColor = color;
        break;

    case MODE_FG:
        float a = texture(text, glyph_tex_coords).r;
        FragColor = vec4(color.rgb, color.a*a);
        break;

    case MODE_CURSOR_RECT:
        FragColor = color;
        break;

    case MODE_CURSOR_RECT_HOLLOW:
        // Okay so yeah this is probably horrendously slow and a shader
        // should never do this, but we only ever render a cursor for ONE
        // rectangle so we take the slowdown for that one.

        // Default to no color.
        FragColor = vec4(0., 0., 0., 0.);

        // We subtracted one from cell size because our coordinates start at 0.
        // So a width of 50 means max pixel of 49.
        vec2 cell_size_coords = cell_size - 1;

        // Apply padding
        vec2 padding = vec2(1.,1.);
        cell_size_coords = cell_size_coords - (padding * 2);
        vec2 screen_cell_pos_padded = screen_cell_pos + padding;

        // Convert our frag coord to offset of this cell. We have to subtract
        // 0.5 because the frag coord is in center pixels.
        vec2 cell_frag_coord = gl_FragCoord.xy - screen_cell_pos_padded - 0.5;

        // If the frag coords are in the bounds, then we color it.
        const float eps = 0.1;
        if (cell_frag_coord.x >= 0 && cell_frag_coord.y >= 0 &&
                cell_frag_coord.x <= cell_size_coords.x &&
                cell_frag_coord.y <= cell_size_coords.y) {
            if (abs(cell_frag_coord.x) < eps ||
                    abs(cell_frag_coord.x - cell_size_coords.x) < eps ||
                    abs(cell_frag_coord.y) < eps ||
                    abs(cell_frag_coord.y - cell_size_coords.y) < eps) {
                FragColor = color;
            }
        }

        break;
    }
}
