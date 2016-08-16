# encoding: utf-8
require 'flatten'
require 'json'

describe Flatten do

	it 'has a version number' do
		expect(Flatten::VERSION).not_to be nil
	end


	let(:source_hash) do
		{'bob' => {'bar' => {'baz' => 'bingo', 'whee' => {}}}, 'asdf' => 'qwer'}
	end
	let(:hash_result) do
		{
			'baz' => 'bingo',
			'whee' => {},
			'asdf' => 'qwer',
		}
	end

	let(:source_json) do
		source_hash.to_json
	end
	let(:json_result) do
		hash_result.to_json
	end


	let(:source_hash2) do
		{
			"property" => {
				"dunwoody-home" => {
					"dh-description" => "my house in dunwoody",
					"address" => {
						"dh-street" => "5252 vernon lake drive",
						"dh-city" => "atlanta",
						"dh-state" => "GA"
					}
				}
			},
			"name" => "bob"
		}
	end
	let(:hash_result2) do
		{
			"dh-description" => "my house in dunwoody",
			"dh-street" => "5252 vernon lake drive",
			"dh-city" => "atlanta",
			"dh-state" => "GA",
			"name" => "bob"
		}
	end

	let(:source_json2) do
		source_hash2.to_json
	end
	let(:json_result2) do
		hash_result2.to_json
	end


	it 'should work' do
		expect({'name' => 'bob'}.smash).to eq({'name' => 'bob'})

		expect(source_hash.smash).to eq(hash_result)
		expect(source_hash2.smash).to eq(hash_result2)

		expect(source_json.smash).to eq(json_result)
		expect(source_json2.smash).to eq(json_result2)

	end

end
