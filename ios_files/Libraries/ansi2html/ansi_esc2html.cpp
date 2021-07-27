/*
 * Copyright (c) 2019-2020 Mikhail Bryukhovets
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

#include "ansi_esc2html.h"

#include <algorithm>
#include <array>
#include <deque>
#include <iostream>
#include <sstream>
#include <string>
#include <type_traits>
#include <unordered_map>
#include <vector>

std::string_view close_tag_value[] = {
    // It would be nice place to have designated initializer for arrays in C++:
    // [Tag::BOLD] = "</b>",
    // instead of error-prone:
    "</b>",
    "</i>",
    "</u>",
    "</s>",
    "</font>",
    "</span>"
};

std::string_view open_tag_value[] = {
    // It would be nice place to have designated initializer for arrays in C++:
    // [Tag::BOLD] = "</b>",
    // instead of error-prone:
    "<b>",
    "<i>",
    "<u>",
    "<s>",
    "<font>",
    "<span>"
};

std::array<std::string_view, 256> colors_256 = {
    //standard colros based on Ubuntu color theme. Change to X-term colors?
    "#000000",        // Black
    "#de382b",        // Red
    "#39b54a",        // Green
    "#ffc706",        // Yellow
    "#006fb8",        // Blue
    "#762671",        // Magenta
    "#2cb5e9",        // Cyan
    "#cccccc",        // White
    "#808080",        // Bright Black
    "#ff0000",        // Bright Red
    "#00ff00",        // Bright Green
    "#ffff00",        // Bright Yellow
    "#0000ff",        // Bright Blue
    "#ff00ff",        // Bright Magenta
    "#00ffff",        // Bright Cyan
    "#ffffff",        // Bright White

//color table generation
//based on https://unix.stackexchange.com/a/269085
//16 + 36 × r + 6 × g + b
//     for (unsigned char i = 16; i <= 231; ++i) {
//         int r = (i - 16) / 36;
//         r = !r ? 0 : r * 40 + 55;                           // What are 40 and 55 ?
//         int g = (i - 16) / 6 % 6;
//         g = !g ? 0 : g * 40 + 55;
//         int b = (i - 16) % 6;
//         b = !b ? 0 : b * 40 + 55;
//         QString col = QString("#%1%2%3").arg(r, 2, 16, QLatin1Char('0')).arg(g, 2, 16, QLatin1Char('0')).arg(b, 2, 16, QLatin1Char('0'));
//         if (col != colors_256[i])
//             qFatal("color miss %s %s", colors_256[i], qPrintable(col));
//     }

    "#000000",
    "#00005f",
    "#000087",
    "#0000af",
    "#0000d7",
    "#0000ff",
    "#005f00",
    "#005f5f",
    "#005f87",
    "#005faf",
    "#005fd7",
    "#005fff",
    "#008700",
    "#00875f",
    "#008787",
    "#0087af",
    "#0087d7",
    "#0087ff",
    "#00af00",
    "#00af5f",
    "#00af87",
    "#00afaf",
    "#00afd7",
    "#00afff",
    "#00d700",
    "#00d75f",
    "#00d787",
    "#00d7af",
    "#00d7d7",
    "#00d7ff",
    "#00ff00",
    "#00ff5f",
    "#00ff87",
    "#00ffaf",
    "#00ffd7",
    "#00ffff",
    "#5f0000",
    "#5f005f",
    "#5f0087",
    "#5f00af",
    "#5f00d7",
    "#5f00ff",
    "#5f5f00",
    "#5f5f5f",
    "#5f5f87",
    "#5f5faf",
    "#5f5fd7",
    "#5f5fff",
    "#5f8700",
    "#5f875f",
    "#5f8787",
    "#5f87af",
    "#5f87d7",
    "#5f87ff",
    "#5faf00",
    "#5faf5f",
    "#5faf87",
    "#5fafaf",
    "#5fafd7",
    "#5fafff",
    "#5fd700",
    "#5fd75f",
    "#5fd787",
    "#5fd7af",
    "#5fd7d7",
    "#5fd7ff",
    "#5fff00",
    "#5fff5f",
    "#5fff87",
    "#5fffaf",
    "#5fffd7",
    "#5fffff",
    "#870000",
    "#87005f",
    "#870087",
    "#8700af",
    "#8700d7",
    "#8700ff",
    "#875f00",
    "#875f5f",
    "#875f87",
    "#875faf",
    "#875fd7",
    "#875fff",
    "#878700",
    "#87875f",
    "#878787",
    "#8787af",
    "#8787d7",
    "#8787ff",
    "#87af00",
    "#87af5f",
    "#87af87",
    "#87afaf",
    "#87afd7",
    "#87afff",
    "#87d700",
    "#87d75f",
    "#87d787",
    "#87d7af",
    "#87d7d7",
    "#87d7ff",
    "#87ff00",
    "#87ff5f",
    "#87ff87",
    "#87ffaf",
    "#87ffd7",
    "#87ffff",
    "#af0000",
    "#af005f",
    "#af0087",
    "#af00af",
    "#af00d7",
    "#af00ff",
    "#af5f00",
    "#af5f5f",
    "#af5f87",
    "#af5faf",
    "#af5fd7",
    "#af5fff",
    "#af8700",
    "#af875f",
    "#af8787",
    "#af87af",
    "#af87d7",
    "#af87ff",
    "#afaf00",
    "#afaf5f",
    "#afaf87",
    "#afafaf",
    "#afafd7",
    "#afafff",
    "#afd700",
    "#afd75f",
    "#afd787",
    "#afd7af",
    "#afd7d7",
    "#afd7ff",
    "#afff00",
    "#afff5f",
    "#afff87",
    "#afffaf",
    "#afffd7",
    "#afffff",
    "#d70000",
    "#d7005f",
    "#d70087",
    "#d700af",
    "#d700d7",
    "#d700ff",
    "#d75f00",
    "#d75f5f",
    "#d75f87",
    "#d75faf",
    "#d75fd7",
    "#d75fff",
    "#d78700",
    "#d7875f",
    "#d78787",
    "#d787af",
    "#d787d7",
    "#d787ff",
    "#d7af00",
    "#d7af5f",
    "#d7af87",
    "#d7afaf",
    "#d7afd7",
    "#d7afff",
    "#d7d700",
    "#d7d75f",
    "#d7d787",
    "#d7d7af",
    "#d7d7d7",
    "#d7d7ff",
    "#d7ff00",
    "#d7ff5f",
    "#d7ff87",
    "#d7ffaf",
    "#d7ffd7",
    "#d7ffff",
    "#ff0000",
    "#ff005f",
    "#ff0087",
    "#ff00af",
    "#ff00d7",
    "#ff00ff",
    "#ff5f00",
    "#ff5f5f",
    "#ff5f87",
    "#ff5faf",
    "#ff5fd7",
    "#ff5fff",
    "#ff8700",
    "#ff875f",
    "#ff8787",
    "#ff87af",
    "#ff87d7",
    "#ff87ff",
    "#ffaf00",
    "#ffaf5f",
    "#ffaf87",
    "#ffafaf",
    "#ffafd7",
    "#ffafff",
    "#ffd700",
    "#ffd75f",
    "#ffd787",
    "#ffd7af",
    "#ffd7d7",
    "#ffd7ff",
    "#ffff00",
    "#ffff5f",
    "#ffff87",
    "#ffffaf",
    "#ffffd7",
    "#ffffff",

    //grays
    "#080808",
    "#121212",
    "#1c1c1c",
    "#262626",
    "#303030",
    "#3a3a3a",
    "#444444",
    "#4e4e4e",
    "#585858",
    "#626262",
    "#6c6c6c",
    "#767676",
    "#808080",
    "#8a8a8a",
    "#949494",
    "#9e9e9e",
    "#a8a8a8",
    "#b2b2b2",
    "#bcbcbc",
    "#c6c6c6",
    "#d0d0d0",
    "#dadada",
    "#e4e4e4",
    "#eeeeee"
};

class ANSI_SGR2HTML::impl
{
    using SGRParts = std::deque<unsigned char>;
public:
    std::string parse(std::string_view raw_data, bool strict);
    
private:
    const char C_ESC = 0x1B;    //Esc ASCII code
    enum class Tag : int {  //supposed to be used as int
        BOLD,
        ITALIC,
        UNDERLINE,
        CROSS_OUT,
        FG_COLOR,
        BG_COLOR
    };
    //can't constexpr maps so other trick is used
    static const std::unordered_map<unsigned char, std::string_view> colors_basic_;

    SGRParts splitSGR(std::string_view data);
    void processSGR(SGRParts &&sgr_parts, std::string &out, bool strict = false);
    void appendHTMLSymbol(char symbol, std::string &out);
    void appendHexNumber(unsigned int num, std::string &out);
    void resetAll(std::string& out);    //doesn't matter strict or not
    void resetAttribute(Tag attribute, unsigned int& attribute_counter, std::string& out, bool strict);
    std::string_view decodeColor256(unsigned char color_code);
    std::string_view decodeColorBasic(unsigned char color_code);

    std::vector<Tag> stack_all_;
    std::vector<std::string> string_stack_all_;
    unsigned int counter_intensity_ = 0;
    unsigned int counter_italic_    = 0;
    unsigned int counter_underline_ = 0;
    unsigned int counter_cross_out_ = 0;
    unsigned int counter_fg_color_  = 0;
    unsigned int counter_bg_color_  = 0;
};

std::string ANSI_SGR2HTML::impl::parse(std::string_view raw_data, bool strict)
{
    std::string out_s;
    std::string param_bytes_buf;
    out_s.reserve(raw_data.size()); //very approximate reservation
    //NOTE: Use apostrophes ' not quotes " inside style quotation marks!
    out_s.append(R"(<body style="background-color:#111111;font-family:'Consolas','Droid Sans Mono',monospace; color:#eeeeee; white-space:pre">)");
    bool esc_set = false;
    bool csi_set = false;
    for(const char& c : raw_data) {
        if (C_ESC == c) {                                   // Esc 0x1B
            if(esc_set) {
                // probably broken CSI or was processing unsupported CSI
//                std::cerr << "ANSI_SGR2HTML: broken or unsupported CSI" << std::endl;
                param_bytes_buf.clear();
                csi_set = false;
            }
            esc_set = true;
            continue;
        }
        if ('[' == c) {                                    // [ 0x5B
            if (esc_set) {
                csi_set = true;
            } else {
                appendHTMLSymbol(c, out_s);
            }
            continue;
        }
        if ('m' == c) {
            if (csi_set && esc_set) {                               // end of ESC-SGR последовательности
                processSGR( splitSGR(param_bytes_buf), out_s, strict);
                param_bytes_buf.clear();
                csi_set = esc_set = false;                          // end of ESC
            } else {
                appendHTMLSymbol(c, out_s);
            }
            continue;
        }
        if (0x30 <= c && 0x3F >= c) {                       // fill SGR. Valid SGR parameter bytes are 0123456789:;<=>?
            if (csi_set && esc_set) {
                param_bytes_buf.push_back(c);
            } else {
                appendHTMLSymbol(c, out_s);
            }
            continue;
        }
        if(esc_set || csi_set) {                            // no valid CSI symbols but ESC or CSI set
            continue;
        }
        if ('\n' == c) {                                    // LF 0x0a
            //FIXME: what about CR and CRLF sequence?
            out_s.append("<br />");
            continue;
        }
        appendHTMLSymbol(c, out_s);                  //default
    }
    resetAll(out_s);                                //closes remaining tags
    out_s.append("</body>");
    return out_s;
}

ANSI_SGR2HTML::impl::SGRParts ANSI_SGR2HTML::impl::splitSGR(std::string_view data)
{
    SGRParts sgr_parts;
//    auto it = data.begin();
//    while(it != data.end()) {
//        it = std::find_if(it, data.end(), static_cast<int(*)(int)>(isdigit));
//        auto ed = std::find_if_not(it, data.end(), static_cast<int(*)(int)>(isdigit));
//        if(it!=data.end()) {
//            unsigned char val = 0;
//            auto result = std::from_chars(&(*it), &(*ed), val);   // val unmodified instead of overflow. Could check return value for results
//            sgr_parts.push_back(val);
//        }
//        it = ed;
//    }

    // ~30% faster
    unsigned char v = 0;
    bool has_digit = false;
    for(const char& cc: data) {
        if(isdigit(cc)) {
            v = static_cast<unsigned char>(v * 10 + (cc-'0'));  //Part of SGR are 0..255 so unsigned char overflow happen only for incorrect data.
            has_digit = true;
        } else if(has_digit) {
            sgr_parts.push_back(v);
            v = 0;
            has_digit = false;
        }
    }
    if(has_digit) {
        sgr_parts.push_back(v);
    }
    return sgr_parts;
}


//TODO: 
void ANSI_SGR2HTML::impl::processSGR(SGRParts&& sgr_parts/*is rvalue ref any good here?*/, std::string& out/*non const!*/, bool strict)
{
    if (sgr_parts.empty())
        return;                                         // Nothing to parse
    unsigned char sgr_code = sgr_parts[0];

    switch (sgr_code) {
    case 0:                                                 // Reset / Normal	all attributes off
        resetAll(out);
        break;
    case 1:                                                 // Bold or increased intensity
        out.append("<b>");
        if(strict)
            string_stack_all_.push_back("<b>");
        stack_all_.push_back(Tag::BOLD);
        counter_intensity_++;
        break;
    case 3:                                                 // Italic
        out.append("<i>");
        if(strict)
            string_stack_all_.push_back("<i>");
        stack_all_.push_back(Tag::ITALIC);
        counter_italic_++;
        break;
    case 4:                                                 // Underline
        out.append("<u>");
        if(strict)
            string_stack_all_.push_back("<u>");
        stack_all_.push_back(Tag::UNDERLINE);
        counter_underline_++;
        break;
    case 9:                                                 // Crossed-out
        out.append("<s>");
        if(strict)
            string_stack_all_.push_back("<s>");
        stack_all_.push_back(Tag::CROSS_OUT);
        counter_cross_out_++;
        break;
    case 22:                                                // Normal color or intensity
        resetAttribute(Tag::BOLD, counter_intensity_, out, strict);
        break;
    case 23:                                                // Not italic, not Fraktur
        resetAttribute(Tag::ITALIC, counter_italic_, out, strict);
        break;
    case 24:                                                // Underline off
        resetAttribute(Tag::UNDERLINE, counter_underline_, out, strict);
        break;
    case 29:                                                // Not crossed out
        resetAttribute(Tag::CROSS_OUT, counter_cross_out_, out, strict);
        break;
    case 39:                                                // Default foreground color
        resetAttribute(Tag::FG_COLOR, counter_fg_color_, out, strict);
        break;
    case 49:                                                // Default background color
        resetAttribute(Tag::BG_COLOR, counter_bg_color_, out, strict);
        break;
    case 38:                                                // Set foreground color
        if (5 == sgr_parts[1] && sgr_parts.size() >= 3) {   // 8-bit foreground color // 38:5:⟨n⟩
            // OPTIMIZATION: foreground and background cases are very similar. Extract them as function?
//            static const std::string_view font_color_tag{R"(<font color=")"};
//            out.append(font_color_tag); // OPTIMIZATION: const char* can be replaced with string_view
            out.append(R"(<font color=")");
            out.append(decodeColor256(sgr_parts[2]));
            out.append(R"(">)");
            sgr_parts.erase(sgr_parts.begin(), sgr_parts.begin() + 3);
            if(strict) {
                std::string ts;
                ts.reserve(22);
                ts.append(R"(<font color=")");
                ts.append(decodeColor256(sgr_parts[2]));
                ts.append(R"(">)");
                string_stack_all_.push_back(ts);
            } 
            stack_all_.push_back(Tag::FG_COLOR);
            counter_fg_color_++;
            // 24-bit foreground color //38;2;⟨r⟩;⟨g⟩;⟨b⟩
        } else if (2 == sgr_parts[1] && sgr_parts.size() >= 5) {
            out.append(R"(<font color="#)");
            appendHexNumber(sgr_parts[2], out);
            appendHexNumber(sgr_parts[3], out);
            appendHexNumber(sgr_parts[4], out);
            out.append(R"(">)");
            sgr_parts.erase(sgr_parts.begin(), sgr_parts.begin() + 5);
            if(strict) {
                std::string ts;
                ts.reserve(22);
                ts.append(R"(<font color="#)");
                appendHexNumber(sgr_parts[2], ts);
                appendHexNumber(sgr_parts[3], ts);
                appendHexNumber(sgr_parts[4], ts);
                ts.append(R"(">)");
                string_stack_all_.push_back(ts);
            } 
            stack_all_.push_back(Tag::FG_COLOR);
            counter_fg_color_++;
        } else {
            return;
        }
        break;
    case 48:                                                // Set background color
        if (5 == sgr_parts[1] && sgr_parts.size() >= 3) {   // 8-bit background color // 48:5:⟨n⟩
            out.append(R"(<span style="background-color:)");
            out.append(decodeColor256(sgr_parts[2]));
            out.append(R"(">)");
            sgr_parts.erase(sgr_parts.begin(), sgr_parts.begin() + 3);
            if(strict) {
                std::string ts;
                ts.reserve(39);
                ts.append(R"(<span style="background-color:)");
                ts.append(decodeColor256(sgr_parts[2]));
                ts.append(R"(">)");
                string_stack_all_.push_back(ts);
            }
            stack_all_.push_back(Tag::BG_COLOR);
            counter_bg_color_++;
            // 24-bit background color //48;2;⟨r⟩;⟨g⟩;⟨b⟩
        } else if (2 == sgr_parts[1] && sgr_parts.size() >= 5) {
            out.append(R"(<span style="background-color:#)");
            appendHexNumber(sgr_parts[2], out);
            appendHexNumber(sgr_parts[3], out);
            appendHexNumber(sgr_parts[4], out);
            out.append(R"(">)");
            sgr_parts.erase(sgr_parts.begin(), sgr_parts.begin() + 5);
            if(strict) {
                std::string ts;
                ts.reserve(39);
                ts.append(R"(<span style="background-color:#)");
                appendHexNumber(sgr_parts[2], ts);
                appendHexNumber(sgr_parts[3], ts);
                appendHexNumber(sgr_parts[4], ts);
                ts.append(R"(">)");
                string_stack_all_.push_back(ts);
            } 
            stack_all_.push_back(Tag::BG_COLOR);
            counter_bg_color_++;
        } else {
            return;
        }
        break;

    default:                                                // SGR code ranges
        if (
                (30 <= sgr_code && 37 >= sgr_code) ||
                (90 <= sgr_code && 97 >= sgr_code)
           ) {                                              // foreground color from table
            // For now using <font color> instead of <span style>. It is little shorter and should not break in most of cases.
            out.append(R"(<font color=")");                 // Not very beautilful string construction. Can use {fmt} or wait for С++20 with eel.is/c++draft/format.
            out.append(decodeColorBasic(sgr_code));
            out.append(R"(">)");
            if(strict) {
                std::string ts;
                ts.reserve(22);
                ts.append(R"(<font color=")");
                ts.append(decodeColorBasic(sgr_code));
                ts.append(R"(">)");
                string_stack_all_.push_back(ts);
            } 
            stack_all_.push_back(Tag::FG_COLOR);
            counter_fg_color_++;
        } else if (
                   (40 <= sgr_code && 47 >= sgr_code) ||
                   (100 <= sgr_code && 107 >= sgr_code)
                  ) {                                       // background color from table
            out.append(R"(<span style="background-color:)");
            out.append(decodeColorBasic(sgr_code));
            out.append(R"(">)");
            if(strict) {
                std::string ts;
                ts.reserve(39);
                ts.append(R"(<span style="background-color:)");
                ts.append(decodeColorBasic(sgr_code));
                ts.append(R"(">)");
                string_stack_all_.push_back(ts);
            } 
            stack_all_.push_back(Tag::BG_COLOR);
            counter_bg_color_++;
        } else {
//            std::cerr << "ANSI_SGR2HTML: unsupported SGR: " <<  static_cast<unsigned int>(sgr_code) << std::endl;
        }
    }

    // Pop processed parameters
    if (sgr_code != 38 && sgr_code != 48)  {  // All parameters except 38 and 48 contain single SGR part. 38 and 48 clean themselves (can pop 3 or 5)
        sgr_parts.pop_front();
    }

    if (sgr_parts.empty())                                  // No more parameters
        return;                                         // OPTIMIZATION: same check is in the beginning of function. Is this one redundant or is it worth not to call processSGR one more time vs checks?

    processSGR(std::forward<SGRParts>(sgr_parts), out, strict);
}

void ANSI_SGR2HTML::impl::appendHTMLSymbol(char symbol, std::string& out)
{
    static const std::string_view quot{"&quot;"};
    static const std::string_view apos{"&apos;"};
    static const std::string_view amp {"&amp;" };
    static const std::string_view lt  {"&lt;"  };
    static const std::string_view gt  {"&gt;"  };
    switch (symbol) {
    case '"':
        out.append(quot);
        break;
    case '\'':
        out.append(apos);
        break;
    case '&':
        out.append(amp);
        break;
    case '<':
        out.append(lt);
        break;
    case '>':
        out.append(gt);
        break;
    case '\0':  //\0 is isgnored.
        break;
    default:
        out.append(&symbol, 1);
    }
}


void ANSI_SGR2HTML::impl::appendHexNumber(unsigned int num, std::string& out)
{
    //based on charconv's __to_chars_16. But have leading zero. Original to_chars don't add leading zero
    static constexpr char digits[] = {
        '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
        'a', 'b', 'c', 'd', 'e', 'f'
    };

    const auto num2 = num & 0xF;
    num >>= 4;
    out.push_back(digits[num]);
    out.push_back(digits[num2]);
}


void ANSI_SGR2HTML::impl::resetAll(std::string& out)
{
    for(auto ri = stack_all_.rbegin(); ri != stack_all_.rend(); ++ri) { //FASTER then by index ?!
        out.append(close_tag_value[static_cast<int>(*ri)]);
    }

//     for(int i=stack_all_.size()-1; i>=0; --i)
//         out.append(close_tag_value[static_cast<int>(stack_all_[i])]);

    stack_all_.clear();
    string_stack_all_.clear();
    counter_intensity_ = 0;
    counter_italic_    = 0;
    counter_underline_ = 0;
    counter_cross_out_ = 0;
    counter_fg_color_  = 0;
    counter_bg_color_  = 0;
}


std::string_view ANSI_SGR2HTML::impl::decodeColor256(unsigned char color_code)
{
    return colors_256[color_code];
}

std::string_view ANSI_SGR2HTML::impl::decodeColorBasic(unsigned char color_code)
{
    static const std::array<std::string_view, 16> colors_basic = {
        "#000000",
        "#de382b",
        "#39b54a",
        "#ffc706",
        "#006fb8",
        "#762671",
        "#2cb5e9",
        "#cccccc",
        "#808080",
        "#ff0000",
        "#00ff00",
        "#ffff00",
        "#0000ff",
        "#ff00ff",
        "#00ffff",
        "#ffffff"
    };
    if(color_code-30 < 8) { // range check 30-37. color_code is unsigned char so will overflow if color_code is less then 30
        color_code = color_code-30;
    } else if(color_code-40 < 8) {
        color_code = color_code-40;
    } else if(color_code-90 < 8) {
        color_code = color_code - 90 + 8;
    } else if(color_code-100 < 8) {
        color_code = color_code - 100 + 8;
    } else {
        return "ffffff";
    }
    return colors_basic[color_code];    //no additional range check with .at() required
}


/**
 * @brief ANSI_SGR2HTML::impl::resetAttribute
 * @param tag
 * @param attribute_counter
 * @param out
 * NOTE: attribute_counter passed as reference
 */
void ANSI_SGR2HTML::impl::resetAttribute(Tag tag, unsigned int& attribute_counter, std::string& out, bool strict)
{
    if(strict) {
        for(;attribute_counter>0; --attribute_counter) {
            size_t t_i = stack_all_.size()-1;
            while(stack_all_[t_i] != tag) {
                out.append(close_tag_value[static_cast<int>(stack_all_[t_i])]);
                --t_i;
            }
            out.append(close_tag_value[static_cast<int>(stack_all_[t_i])]);

            for(;t_i < stack_all_.size()-1; ++t_i) {
                out.append(string_stack_all_[t_i+1]);
                stack_all_[t_i] = stack_all_[t_i+1];
                string_stack_all_[t_i] = string_stack_all_[t_i+1];
            }
            stack_all_.pop_back();
            string_stack_all_.pop_back();
            
            
            
            /*            
            Tag toptag = stack_all_.back();
            while(toptag != tag) {
                stack_reopen_.push_back(stack_all_.back());
                string_stack_reopen_.push_back(string_stack_all_.back()); 
                out.append(close_tag_value[static_cast<int>(stack_all_.back())]);
                //             out.append(string_stack_all_.back());
                stack_all_.pop_back();
                string_stack_all_.pop_back();
                toptag = stack_all_.back();
            }
            out.append(close_tag_value[static_cast<int>(stack_all_.back())]);
            stack_all_.pop_back();
            while(!stack_reopen_.empty()) {
                //             out.append(open_tag_value[static_cast<int>(stack_reopen_.top())]);
                out.append(string_stack_reopen_.back());
                stack_all_.push_back(stack_reopen_.back());
                string_stack_all_.push_back(string_stack_reopen_.back());
                stack_reopen_.pop_back();
                string_stack_reopen_.pop_back();
            }
            */
        }

    } else {
        for(;attribute_counter>0; --attribute_counter) {
            out.append(close_tag_value[static_cast<int>(stack_all_.back())]);
            stack_all_.pop_back();
        }
    }
}

// ANSI_SGR2HTML
ANSI_SGR2HTML::ANSI_SGR2HTML() :
    pimpl_(new impl)
{
}

ANSI_SGR2HTML::~ANSI_SGR2HTML()
= default;

std::string ANSI_SGR2HTML::simpleParse(const std::string &raw_data)
{
    return pimpl_->parse(raw_data, false);
}

std::string ANSI_SGR2HTML::strictParse(const std::string &raw_data)
{
    return pimpl_->parse(raw_data, true);
}
