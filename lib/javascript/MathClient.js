

function Math(url, auth, auth_cb, timeout, async_job_check_time_ms) {
    var self = this;

    this.url = url;
    var _url = url;

    this.timeout = timeout;
    var _timeout = timeout;
    
    this.async_job_check_time_ms = async_job_check_time_ms;
    if (!this.async_job_check_time_ms)
        this.async_job_check_time_ms = 5000;

    var _auth = auth ? auth : { 'token' : '', 'user_id' : ''};
    var _auth_cb = auth_cb;


    this.add = function (a, b, _callback, _errorCallback) {
        self.add_async(a, b, function(job_id) {
            var _checkCallback = null;
            _checkCallback = function(job_state) {
                if (job_state.finished != 0) {
                    if (!job_state.hasOwnProperty('result'))
                        job_state.result = null;
                    _callback(job_state.result[0]);
                } else {
                    setTimeout(function () {
                        self.add_check(job_id, _checkCallback, _errorCallback);
                    }, self.async_job_check_time_ms);
                }
            };       
            _checkCallback({finished: 0});
        }, _errorCallback);
    };

    this.add_async = function (a, b, _callback, _errorCallback) {
        if (typeof a === 'function')
            throw 'Argument a can not be a function';
        if (typeof b === 'function')
            throw 'Argument b can not be a function';
        if (_callback && typeof _callback !== 'function')
            throw 'Argument _callback must be a function if defined';
        if (_errorCallback && typeof _errorCallback !== 'function')
            throw 'Argument _errorCallback must be a function if defined';
        if (typeof arguments === 'function' && arguments.length > 2+2)
            throw 'Too many arguments ('+arguments.length+' instead of '+(2+2)+')';
        return json_call_ajax("Math.add_async", 
            [a, b], 1, _callback, _errorCallback);
    };
    
    this.add_check = function (job_id, _callback, _errorCallback) {
        if (typeof job_id === 'function')
            throw 'Argument job_id can not be a function';
        if (_callback && typeof _callback !== 'function')
            throw 'Argument _callback must be a function if defined';
        if (_errorCallback && typeof _errorCallback !== 'function')
            throw 'Argument _errorCallback must be a function if defined';
        if (typeof arguments === 'function' && arguments.length > 3)
            throw 'Too many arguments ('+arguments.length+' instead of 3)';
        return json_call_ajax("Math.add_check", 
            [job_id], 1, _callback, _errorCallback);
    };
 
    this.bigAdd = function (a, b, _callback, _errorCallback) {
        self.bigAdd_async(a, b, function(job_id) {
            var _checkCallback = null;
            _checkCallback = function(job_state) {
                if (job_state.finished != 0) {
                    if (!job_state.hasOwnProperty('result'))
                        job_state.result = null;
                    _callback(job_state.result[0]);
                } else {
                    setTimeout(function () {
                        self.bigAdd_check(job_id, _checkCallback, _errorCallback);
                    }, self.async_job_check_time_ms);
                }
            };       
            _checkCallback({finished: 0});
        }, _errorCallback);
    };

    this.bigAdd_async = function (a, b, _callback, _errorCallback) {
        if (typeof a === 'function')
            throw 'Argument a can not be a function';
        if (typeof b === 'function')
            throw 'Argument b can not be a function';
        if (_callback && typeof _callback !== 'function')
            throw 'Argument _callback must be a function if defined';
        if (_errorCallback && typeof _errorCallback !== 'function')
            throw 'Argument _errorCallback must be a function if defined';
        if (typeof arguments === 'function' && arguments.length > 2+2)
            throw 'Too many arguments ('+arguments.length+' instead of '+(2+2)+')';
        return json_call_ajax("Math.bigAdd_async", 
            [a, b], 1, _callback, _errorCallback);
    };
    
    this.bigAdd_check = function (job_id, _callback, _errorCallback) {
        if (typeof job_id === 'function')
            throw 'Argument job_id can not be a function';
        if (_callback && typeof _callback !== 'function')
            throw 'Argument _callback must be a function if defined';
        if (_errorCallback && typeof _errorCallback !== 'function')
            throw 'Argument _errorCallback must be a function if defined';
        if (typeof arguments === 'function' && arguments.length > 3)
            throw 'Too many arguments ('+arguments.length+' instead of 3)';
        return json_call_ajax("Math.bigAdd_check", 
            [job_id], 1, _callback, _errorCallback);
    };
  

    /*
     * JSON call using jQuery method.
     */
    function json_call_ajax(method, params, numRets, callback, errorCallback) {
        var deferred = $.Deferred();

        if (typeof callback === 'function') {
           deferred.done(callback);
        }

        if (typeof errorCallback === 'function') {
           deferred.fail(errorCallback);
        }

        var rpc = {
            params : params,
            method : method,
            version: "1.1",
            id: String(Math.random()).slice(2),
        };

        var beforeSend = null;
        var token = (_auth_cb && typeof _auth_cb === 'function') ? _auth_cb()
            : (_auth.token ? _auth.token : null);
        if (token != null) {
            beforeSend = function (xhr) {
                xhr.setRequestHeader("Authorization", token);
            }
        }

        var xhr = jQuery.ajax({
            url: _url,
            dataType: "text",
            type: 'POST',
            processData: false,
            data: JSON.stringify(rpc),
            beforeSend: beforeSend,
            timeout: _timeout,
            success: function (data, status, xhr) {
                var result;
                try {
                    var resp = JSON.parse(data);
                    result = (numRets === 1 ? resp.result[0] : resp.result);
                } catch (err) {
                    deferred.reject({
                        status: 503,
                        error: err,
                        url: _url,
                        resp: data
                    });
                    return;
                }
                deferred.resolve(result);
            },
            error: function (xhr, textStatus, errorThrown) {
                var error;
                if (xhr.responseText) {
                    try {
                        var resp = JSON.parse(xhr.responseText);
                        error = resp.error;
                    } catch (err) { // Not JSON
                        error = "Unknown error - " + xhr.responseText;
                    }
                } else {
                    error = "Unknown Error";
                }
                deferred.reject({
                    status: 500,
                    error: error
                });
            }
        });

        var promise = deferred.promise();
        promise.xhr = xhr;
        return promise;
    }
}


