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

#ifndef ANSI_SGR2HTML_H
#define ANSI_SGR2HTML_H

#include <memory>
#include <string>

/**
 * @todo write docs
 * All functions are reentrant but not thread-safe
 */
class ANSI_SGR2HTML
{
public:
    ANSI_SGR2HTML();
    ~ANSI_SGR2HTML();
    
    /**
     * @brief simpleParse parses string, with ANSI escape sequences to HTML string
     * @param raw_data string to parse
     * @return HTML string
     */
    std::string simpleParse(const std::string& raw_data);
    /**
     */
    std::string strictParse(const std::string& raw_data);

    ANSI_SGR2HTML(const ANSI_SGR2HTML &other) = delete;
    ANSI_SGR2HTML(ANSI_SGR2HTML &&other) = delete;
    ANSI_SGR2HTML &operator=(const ANSI_SGR2HTML &other) = delete;
    ANSI_SGR2HTML &operator=(ANSI_SGR2HTML &&other) = delete;
    
private:
    class impl;
    std::unique_ptr<impl> pimpl_;
};

#endif // ANSI_SGR2HTML_H
