module libmecab.common;

import bindbc.mecab;

shared static this()
{
    const support = loadMeCab();
    assert(support == MeCabSupport.mecab);
}

shared static ~this()
{
    unloadMeCab();
}

struct MeCabModel
{
    private mecab_model_t* handle;

    @disable this();
    @disable this(this);

    package this(mecab_model_t* handle)
    {
        this.handle = handle;
    }

    ~this()
    {
        mecab_model_destroy(this.handle);
    }

    MeCabTagger createTagger()
    {
        return MeCabTagger(mecab_model_new_tagger(handle));
    }

    MeCabLattice createLattice()
    {
        return MeCabLattice(mecab_model_new_lattice(handle));
    }

    static MeCabModel create()
    {
        auto model = mecab_model_new(0, null);
        return MeCabModel(model);
    }

    static MeCabModel create(string arg)
    {
        auto buf = new char[arg.length + 1];
        buf[0 .. $ - 1] = arg[];
        buf[$ - 1] = 0;
        auto model = mecab_model_new2(buf.ptr);
        return MeCabModel(model);
    }
}

struct MeCabTagger
{
    private mecab_t* handle;

    @disable this();
    @disable this(this);

    package this(mecab_t* handle)
    {
        this.handle = handle;
    }

    ~this()
    {
        mecab_destroy(handle);
    }

    MeCabNodeRange parseToNodes(scope ref MeCabLattice lattice)
    {
        mecab_parse_lattice(handle, lattice.handle);
        return MeCabNodeRange(lattice.bosNode());
    }

    MeCabNodeRange parseToNodes(string text)
    {
        auto lattice = MeCabLattice.create();
        lattice.sentence = text;
        return parseToNodes(lattice);
    }

    static MeCabTagger create()
    {
        auto handle = mecab_new(0, null);
        return MeCabTagger(handle);
    }
}

struct MeCabLattice
{
    private mecab_lattice_t* handle;

    @disable this();
    @disable this(this);

    package this(mecab_lattice_t* handle)
    {
        this.handle = handle;
    }

    void sentence(const(char)[] text)
    {
        mecab_lattice_set_sentence2(handle, text.ptr, text.length);
    }

    package mecab_node_t* bosNode()
    {
        return mecab_lattice_get_bos_node(handle);
    }

    static MeCabLattice create()
    {
        return MeCabLattice(mecab_lattice_new());
    }
}

struct MeCabNode
{
    string surface;
    string feature;
    uint id;
    ushort rcAttr;
    ushort lcAttr;
    ushort posId;
    ubyte charType;
    ubyte stat;
    ubyte isBest;
    float alpha;
    float beta;
    float prob;
    long cost;
    short wcost;
}

struct MeCabNodeRange
{
    private mecab_node_t* node;

    @disable this();
    
    this(mecab_node_t* node)
    {
        this.node = node;
    }

    bool empty() const pure nothrow @safe @nogc
    {
        return node is null;
    }

    auto front() const pure nothrow
    in(!empty)
    {
        import std.conv : to;

        return MeCabNode(
            node.surface[0 .. node.length].to!string(),
            node.feature.to!string(),
            node.id,
            node.rcAttr,
            node.lcAttr,
            node.posid,
            node.char_type,
            node.stat,
            node.isbest,
            node.alpha,
            node.beta,
            node.prob,
            node.cost,
            node.wcost
        );
    }

    void popFront() nothrow @safe @nogc
    in(!empty)
    {
        this.node = this.node.next;
    }
}