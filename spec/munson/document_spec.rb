require 'spec_helper'

RSpec.describe Munson::Document do
  describe '#relationship' do
    context 'when the relationship does not exist' do
      it "raises a Munson::RelationshipNotFound error" do
        json = response_json(:artist_9)
        artist = Munson::Document.new(json)

        expect{ artist.relationship(:foos) }.
          to raise_error(Munson::RelationshipNotFound)
      end
    end

    context "when the relationship is not embedded" do
      it "returns the id" do
        json = response_json(:album_1)
        artist = Munson::Document.new(json)

        expect(artist.relationship(:artist)).to be_a(String)
      end

      it "returns ids" do
        json = response_json(:album_2)
        artist = Munson::Document.new(json)

        expect(artist.relationship(:artists)).to be_a(Array)
      end
    end

    context 'when it is a to-many relationship' do
      it "returns related documents" do
        json = response_json(:artist_9_include_albums_record_label)
        artist = Munson::Document.new(json)
        albums = artist.relationship(:albums)

        expect(albums).to be_a(Array)
        expect(albums.first).to be_a(Munson::Document)
      end
    end

    context 'when it is a to-one relationship' do
      it "returns the related document" do
        json = response_json(:artist_9_include_albums_record_label)
        artist = Munson::Document.new(json)

        record_label = artist.relationship(:record_label)
        expect(record_label).to be_a(Munson::Document)
        expect(record_label.type).to be :record_labels
      end
    end
  end

  describe '#id' do
    it "returns the ID of the jsonapi resource" do
      json = response_json(:album_1_include_artist)
      document = Munson::Document.new(json)
      expect(document.id).to eq "1"
    end
  end

  describe '#type' do
    it "returns the type of the jsonapi resource" do
      json = response_json(:album_1_include_artist)
      document = Munson::Document.new(json)
      expect(document.type).to eq :albums
    end
  end

  describe '#attributes' do
    it "returns the attributes of the jsonapi resource" do
      json = response_json(:album_1_include_artist)
      document = Munson::Document.new(json)
      expect(document.attributes).to eq({
        title: "The Crane Wife"
      })
    end
  end

  describe '#relationships' do
    it "returns the relationships of the jsonapi resource" do
      json = response_json(:album_1_include_artist)
      document = Munson::Document.new(json)
      expect(document.relationships).to eq({
        artist: {
          data: { type: "artists", id: "9" },
          links: {
            self: "http://api.example.com/albums/1/relationships/artist",
            related: "http://api.example.com/albums/1/artist"
          }
        }
      })
    end
  end
end
