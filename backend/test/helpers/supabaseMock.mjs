const DEFAULTS = {
  posts: [],
  media: [],
  post_comments: []
};

function buildRow(table, payload, idSeed) {
  const base = {
    id: payload.id || `${table}-${idSeed}`,
    created_at: payload.created_at || new Date().toISOString()
  };

  if (table === "posts") {
    return {
      likes_count: 0,
      remixes_count: 0,
      ...base,
      ...payload
    };
  }

  return { ...base, ...payload };
}

class QueryBuilder {
  constructor(table, state) {
    this.table = table;
    this.state = state;
    this._select = null;
    this._insert = null;
    this._eq = null;
    this._lt = null;
    this._contains = null;
    this._order = null;
    this._limit = null;
    this._single = false;
    this._inserted = null;
  }

  select(fields) {
    this._select = fields;
    return this;
  }

  insert(payload) {
    this._insert = payload;
    return this;
  }

  eq(field, value) {
    this._eq = { field, value };
    return this;
  }

  lt(field, value) {
    this._lt = { field, value };
    return this;
  }

  contains(field, value) {
    this._contains = { field, value };
    return this;
  }

  order(field, options) {
    this._order = { field, ascending: options?.ascending ?? true };
    return this;
  }

  limit(value) {
    this._limit = value;
    return this;
  }

  single() {
    this._single = true;
    return this;
  }

  async _execute() {
    const tableData = this.state[this.table] || [];

    if (this._insert) {
      const payloads = Array.isArray(this._insert) ? this._insert : [this._insert];
      let idSeed = tableData.length + 1;
      const rows = payloads.map((payload) => buildRow(this.table, payload, idSeed++));
      tableData.push(...rows);
      this.state[this.table] = tableData;
      this._inserted = rows;
      return { data: this._single ? rows[0] : rows, error: null };
    }

    let results = [...tableData];

    if (this._eq) {
      results = results.filter((row) => row[this._eq.field] === this._eq.value);
    }

    if (this._lt) {
      results = results.filter((row) => row[this._lt.field] < this._lt.value);
    }

    if (this._contains) {
      const [value] = this._contains.value || [];
      results = results.filter((row) => Array.isArray(row[this._contains.field]) &&
        row[this._contains.field].includes(value)
      );
    }

    if (this._order) {
      const { field, ascending } = this._order;
      results.sort((a, b) => {
        if (a[field] === b[field]) return 0;
        if (ascending) {
          return a[field] > b[field] ? 1 : -1;
        }
        return a[field] < b[field] ? 1 : -1;
      });
    }

    if (Number.isInteger(this._limit)) {
      results = results.slice(0, this._limit);
    }

    if (this._single) {
      const record = results[0];
      if (!record) {
        return { data: null, error: { code: "PGRST116", message: "Not found" } };
      }
      return { data: record, error: null };
    }

    return { data: results, error: null };
  }

  then(resolve, reject) {
    return this._execute().then(resolve, reject);
  }
}

export function createSupabaseMock(seed = {}) {
  const state = {
    ...DEFAULTS,
    ...seed
  };

  const likeCounts = {};
  const remixCounts = {};

  return {
    from(table) {
      return new QueryBuilder(table, state);
    },
    rpc(name, args) {
      if (name === "like_post") {
        const postId = args?.p_post_id;
        likeCounts[postId] = (likeCounts[postId] || 0) + 1;
        return Promise.resolve({ data: likeCounts[postId], error: null });
      }
      if (name === "refresh_remix_count") {
        const postId = args?.p_post_id;
        remixCounts[postId] = (remixCounts[postId] || 0) + 1;
        return Promise.resolve({ data: remixCounts[postId], error: null });
      }
      return Promise.resolve({ data: null, error: null });
    }
  };
}
