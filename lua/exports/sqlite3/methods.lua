
local ffi = require 'ffi'
local lib = require 'exports.sqlite3'

ffi.metatype('sqlite3', {
	__index = {
		exec = lib.sqlite3_exec;
		config = lib.sqlite3_db_config;
		extended_result_codes = lib.sqlite3_extended_result_codes;
		last_insert_rowid = lib.sqlite3_last_insert_rowid;
		changes = lib.sqlite3_changes;
		total_changes = lib.sqlite3_total_changes;
		interrupt = lib.sqlite3_interrupt;
		busy_handler = lib.sqlite3_busy_handler;
		busy_timeout = lib.sqlite3_busy_timeout;
		get_table = lib.sqlite3_get_table;
		set_authorizer = lib.sqlite3_set_authorizer;
		trace = lib.sqlite3_trace;
		profile = lib.sqlite3_profile;
		progress_handler = lib.sqlite3_progress_handler;
		errcode = lib.sqlite3_errcode;
		extended_errcode = lib.sqlite3_extended_errcode;
		errmsg = lib.sqlite3_errmsg;
		errmsg16 = lib.sqlite3_errmsg16;
		errstr = lib.sqlite3_errstr;
		limit = lib.sqlite3_limit;
		prepare = lib.sqlite3_prepare;
		prepare_v2 = lib.sqlite3_prepare_v2;
		prepare16 = lib.sqlite3_prepare16;
		prepare16_v2 = lib.sqlite3_prepare16_v2;
		create_function = lib.sqlite3_create_function;
		create_function16 = lib.sqlite3_create_function16;
		create_function_v2 = lib.sqlite3_create_function_v2;
		create_collation = lib.sqlite3_create_collation;
		create_collation_v2 = lib.sqlite3_create_collation_v2;
		create_collation16 = lib.sqlite3_create_collation16;
		collation_needed = lib.sqlite3_collation_needed;
		collation_needed16 = lib.sqlite3_collation_needed16;
		get_autocommit = lib.sqlite3_get_autocommit;
		filename = lib.sqlite3_db_filename;
		readonly = lib.sqlite3_db_readonly;
		next_stmt = lib.sqlite3_next_stmt;
		commit_hook = lib.sqlite3_commit_hook;
		rollback_hook = lib.sqlite3_rollback_hook;
		update_hook = lib.sqlite3_update_hook;
		db_release_memory = lib.sqlite3_db_release_memory;
		table_column_metadata = lib.sqlite3_table_column_metadata;
		load_extension = lib.sqlite3_load_extension;
		enable_load_extension = lib.sqlite3_enable_load_extension;
		create_module = lib.sqlite3_create_module;
		create_module_v2 = lib.sqlite3_create_module_v2;
		declare_vtab = lib.sqlite3_declare_vtab;
		overload_function = lib.sqlite3_overload_function;
		open_blob = lib.sqlite3_blob_open;
		file_control = lib.sqlite3_file_control;
		status = lib.sqlite3_db_status;
	};
})

ffi.metatype('sqlite3_stmt', {
	__index = {
		sql = lib.sqlite3_sql;
		stmt_readonly = lib.sqlite3_stmt_readonly;
		stmt_busy = lib.sqlite3_stmt_busy;
		bind_blob = lib.sqlite3_bind_blob;
		bind_blob64 = lib.sqlite3_bind_blob64;
		bind_double = lib.sqlite3_bind_double;
		bind_int = lib.sqlite3_bind_int;
		bind_int64 = lib.sqlite3_bind_int64;
		bind_null = lib.sqlite3_bind_null;
		bind_text = lib.sqlite3_bind_text;
		bind_text16 = lib.sqlite3_bind_text16;
		bind_text64 = lib.sqlite3_bind_text64;
		bind_value = lib.sqlite3_bind_value;
		bind_zeroblob = lib.sqlite3_bind_zeroblob;
		bind_zeroblob64 = lib.sqlite3_bind_zeroblob64;
		bind_parameter_count = lib.sqlite3_bind_parameter_count;
		bind_parameter_name = lib.sqlite3_bind_parameter_name;
		bind_parameter_index = lib.sqlite3_bind_parameter_index;
		clear_bindings = lib.sqlite3_clear_bindings;
		column_count = lib.sqlite3_column_count;
		column_name = lib.sqlite3_column_name;
		column_name16 = lib.sqlite3_column_name16;
		--column_database_name = lib.sqlite3_column_database_name;
		--column_database_name16 = lib.sqlite3_column_database_name16;
		--column_table_name = lib.sqlite3_column_table_name;
		--column_table_name16 = lib.sqlite3_column_table_name16;
		--column_origin_name = lib.sqlite3_column_origin_name;
		--column_origin_name16 = lib.sqlite3_column_origin_name16;
		column_decltype = lib.sqlite3_column_decltype;
		column_decltype16 = lib.sqlite3_column_decltype16;
		step = lib.sqlite3_step;
		data_count = lib.sqlite3_data_count;
		column_blob = lib.sqlite3_column_blob;
		column_bytes = lib.sqlite3_column_bytes;
		column_bytes16 = lib.sqlite3_column_bytes16;
		column_double = lib.sqlite3_column_double;
		column_int = lib.sqlite3_column_int;
		column_int64 = lib.sqlite3_column_int64;
		column_text = lib.sqlite3_column_text;
		column_text16 = lib.sqlite3_column_text16;
		column_type = lib.sqlite3_column_type;
		column_value = lib.sqlite3_column_value;
		finalize = lib.sqlite3_finalize;
		reset = lib.sqlite3_reset;
		db_handle = lib.sqlite3_db_handle;
		status = lib.sqlite3_stmt_status;
	};
})

ffi.metatype('sqlite3_value', {
	__index = {
		blob = lib.sqlite3_value_blob;
		bytes = lib.sqlite3_value_bytes;
		bytes16 = lib.sqlite3_value_bytes16;
		double = lib.sqlite3_value_double;
		int = lib.sqlite3_value_int;
		int64 = lib.sqlite3_value_int64;
		text = lib.sqlite3_value_text;
		text16 = lib.sqlite3_value_text16;
		text16le = lib.sqlite3_value_text16le;
		text16be = lib.sqlite3_value_text16be;
		type = lib.sqlite3_value_type;
		numeric_type = lib.sqlite3_value_numeric_type;
		dup = lib.sqlite3_value_dup; -- experimental
		free = lib.sqlite3_value_free; -- experimental
	};
})

ffi.metatype('sqlite3_context', {
	__index = {
		aggregate = lib.sqlite3_aggregate_context;
		user_data = lib.sqlite3_user_data;
		db_handle = lib.sqlite3_context_db_handle;
		get_auxdata = lib.sqlite3_get_auxdata;
		set_auxdata = lib.sqlite3_set_auxdata;
		result_blob = lib.sqlite3_result_blob;
		result_blob64 = lib.sqlite3_result_blob64;
		result_double = lib.sqlite3_result_double;
		result_error = lib.sqlite3_result_error;
		result_error16 = lib.sqlite3_result_error16;
		result_error_toobig = lib.sqlite3_result_error_toobig;
		result_error_nomem = lib.sqlite3_result_error_nomem;
		result_error_code = lib.sqlite3_result_error_code;
		result_int = lib.sqlite3_result_int;
		result_int64 = lib.sqlite3_result_int64;
		result_null = lib.sqlite3_result_null;
		result_text = lib.sqlite3_result_text;
		result_text64 = lib.sqlite3_result_text64;
		result_text16 = lib.sqlite3_result_text16;
		result_text16le = lib.sqlite3_result_text16le;
		result_text16be = lib.sqlite3_result_text16be;
		result_value = lib.sqlite3_result_value;
		result_zeroblob = lib.sqlite3_result_zeroblob;
		result_zeroblob64 = lib.sqlite3_result_zeroblob64;
	};
})

ffi.metatype('sqlite3_blob', {
	__index = {
		reopen = lib.sqlite3_blob_reopen;
		close = lib.sqlite3_blob_close;
		bytes = lib.sqlite3_blob_bytes;
		read = lib.sqlite3_blob_read;
		write = lib.sqlite3_blob_write;
	};
})
