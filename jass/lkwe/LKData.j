library LKHashtable {
    private hashtable ht = InitHashtable();

    public function LKSetBoolean(string key, boolean value) -> nothing {
        SaveBoolean(ht, 0, StringHash(key), value);
    }
    public function LKGetBoolean(string key) -> boolean {
        return LoadBoolean(ht, 0, StringHash(key));
    }
    public function LKCompareBoolean(string key, boolean value) -> boolean {
        return LKGetBoolean(key) == value;
    }

    public function LKSetString(string key, string value) -> nothing {
        SaveStr(ht, 0, StringHash(key), value);
    }
    public function LKGetString(string key) -> string {
        return LoadStr(ht, 0, StringHash(key));
    }
    public function LKCompareString(string key, string value) -> string {
        return LKGetString(key) == value;
    }
}
