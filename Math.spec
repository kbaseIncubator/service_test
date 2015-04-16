
module Math:Math {
	
    typedef list<float> f_vector;
    typedef list<f_vector> f_matrix2;

	funcdef add(f_vector a, f_vector b) returns (f_vector);

	async funcdef bigAdd(f_vector a, f_vector b) returns (f_vector) authentication required;

};

