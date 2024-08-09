module logger;
import std.conv;
import std.array;
import std.stdio;
import std.traits;

enum LogLevel
{
    Debug = "debug",
    Info = "info",
    Warning = "warn",
    Error = "error"
}

string log(T: string)(T value, LogLevel level, string file = __FILE__)
{
    return "[" ~ level ~ "] " ~ file ~ ": " ~ str; 
} 

string log(T)(T value, LogLevel level, string file = __FILE__)
if (is(T == bool) || is(T == int) || is(T == long) || is(T == float) || is(T == double))
{
    string str = to!string(value);
    return "[" ~ level ~ "] " ~ file ~ ": " ~ str; 
}

string log(T: U[], U)(T value, LogLevel level, string file = __FILE__)
{
    auto app = appender(value);
    string str = to!string(app.data);
    return "[" ~ level ~ "] " ~ file ~ ": " ~ str; 
}

string log(T)(T value, LogLevel level, string file = __FILE__)
if (is(T == struct)){
    string name = __traits(identifier, T);
    alias memberList = __traits(allMembers, T);
    string str;
    str = "[" ~ level ~ "] " ~ file ~ ": " ~ name ~ "(";
    static foreach(member; memberList) 
        static if (isFunction!(__traits(getMember, T, member)) == false) {
            mixin("str ~= to!string(" ~ "value." ~ member ~ ");");
            str ~= ", ";
    }
    // static foreach (member; memberList)
    // {
    //     {auto mem = __traits(getMember, value, member);
    //         if (isFunction!(__traits(getMember, T, member)) == false) {
    //             str ~= to!string(mem);
    //             str ~= ", ";
    //         }
    //     }
    // }
    str ~= ")";
    return str;
}

unittest
{
    // TODO: Add unittests for basic types: stirngs, ints, bools, floats
    bool b = true;
    int i = 30;
    long l = 40;
    float f = 3.14;
    double d = 3.15;
    int[] arr = [1, 2, 3];
	assert("[info] logger.d: true" == b.log(LogLevel.Info));
    assert("[info] logger.d: 30" == i.log(LogLevel.Info));
    assert("[info] logger.d: 40" == l.log(LogLevel.Info));
    assert("[info] logger.d: 3.14" == f.log(LogLevel.Info));
    assert("[info] logger.d: 3.15" == d.log(LogLevel.Info));
    assert("[info] logger.d: [1, 2, 3]" == arr.log!(int[], int)(LogLevel.Info));
}

unittest
{
    struct Stats
    {
        long souls;
        bool optional;
        string toString() const
        {
            return "is " ~ (optional ? "" : "not ") ~ "optional, yields " ~
                souls.to!string ~ " souls";
        }

        @Attr(4, "string") int y;
    }

    struct Boss
    {
        string name;
        int number;
        Stats stats;
        string toString() const
        {
            return "hei";
        }
    }

    Boss firstBoss = Boss("Iudex Gundyr", 1, Stats(3000, false));
    writeln(firstBoss.log(LogLevel.Warning));
    assert("[warn] logger.d: Boss(Iudex Gundyr, 1, is not optional, yields 3000 souls, )" 
    == firstBoss.log(LogLevel.Warning));
}
