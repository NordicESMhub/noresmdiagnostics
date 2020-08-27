---
layout: default
permalink: /license/
---

## Credit

This material is provided by [{{ site.author.name }}]({{ site.author.link }}) under the licenses stated below.

### Website template

The website template is maintained by [CodeRefinery](https://coderefinery.org/) and rendered with [Jekyll](https://jekyllrb.com).
The lesson Jekyll file structure and browsing layout is inspired by and derived from
work by [Software Carpentry](https://software-carpentry.org) licensed under the
[Creative Commons Attribution license (CC-BY-4.0)](https://creativecommons.org/licenses/by/4.0/).
We have kept the YAML structure in the episode Markdown files for future compatibility
but have heavily cut down and modified the layout and include files.
We have copied and adapted most of their
[license text](https://software-carpentry.org/license/).


## License

### Instructional Material

All {{ site.author.name }} instructional material is made available under the
[Creative Commons Attribution license (CC-BY-4.0)](https://creativecommons.org/licenses/by/4.0/).
The following is a human-readable summary of (and not a substitute for)
the [full legal text of the CC-BY-4.0 license](https://creativecommons.org/licenses/by/4.0/legalcode).

You are free:

- to **Share** - copy and redistribute the material in any medium or format
- to **Adapt** - remix, transform, and build upon the material

for any purpose, even commercially. The licensor cannot revoke these freedoms as long as you follow these license terms:

- **Attribution** - You must give appropriate credit
  (mentioning that your work is derived from work that is Copyright
  (c) CodeRefinery and, where practical, linking to
  https://coderefinery.org), provide
  a [link to the license](https://creativecommons.org/licenses/by/4.0/),
  and indicate if changes were made. You may do so in any
  reasonable manner, but not in any way that suggests the licensor
  endorses you or your use.

**No additional restrictions** - You may not apply legal terms or technological
measures that legally restrict others from doing anything the license permits.
With the understanding that:

- You do not have to comply with the license for elements of the material in
  the public domain or where your use is permitted by an applicable exception
  or limitation.
- No warranties are given. The license may not give you all of the
  permissions necessary for your intended use. For example, other
  rights such as publicity, privacy, or moral rights may limit how
  you use the material.


### Software

{% if site.license.code == 'Apache-2.0' -%}
Except where otherwise noted, the example programs and other software provided
by {{ site.author.name }} are made available under the
[OSI](http://opensource.org)-approved
[Apache 2.0 license](https://opensource.org/licenses/Apache-2.0):

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
{% elsif site.license.code == 'MIT' -%}
Except where otherwise noted, the example programs and other software provided
by {{ site.author.name }} are made available under the
[OSI](http://opensource.org)-approved
[MIT license](http://opensource.org/licenses/mit-license.html):

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use, copy,
modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the
Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
{% else -%}
Please refer to the authors for license information!
{% endif -%}
