# libmecab

## Usage

```d
import std.stdio;

import libmecab;

void main()
{
    auto tagger = MeCabTagger.create();
    auto nodes = tagger.parseToNodes("すもももももももものうち");
    foreach (node; nodes)
    {
        writeln(node.surface, '\t', node.feature);
    }
}
```
