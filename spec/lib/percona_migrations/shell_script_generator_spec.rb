require 'percona_migrations'

RSpec.describe "Percona::MigrationCreator" do
    let(:valid_version) { 20140505235630 }
    let(:subject) { PerconaMigrations::ShellScriptGenerator.new valid_version }

    it "raises an exception if version is not found" do
        expect {
            PerconaMigrations::ShellScriptGenerator.new "THISVERSIONDOESNOTEXIST"
        }.to raise_error.with_message("Migration not found")
    end

    it "finds migration file" do
        path = "./spec/fixtures/20140505235630_alter_table_example.rb"
        expect(subject.source_migration_path).to eq(path)
        expect(subject.source_migration_exists?).to eq(true)
    end

    it "has destination directory and makes sure directory exists" do
        dest_dir = "/tmp/script/percona"
        FileUtils.rm_rf dest_dir
        expect(subject.dest_dir).to eq(dest_dir)
        expect(Dir.exists?("/tmp/script/percona")).to be true
    end

    it "generates an output script path" do
        expect(subject.script_path).to eq("/tmp/script/percona/20140505235630_alter_table_example.sh")
    end

    it "can render a shell script" do
        script_body = subject.render
        expect(script_body.is_a? String).to be true
        subject.write_script!
    end

    it "can write a script to file" do
        # FIXME Clean this up
        migration_body = File.open(subject.source_migration_path).readlines
        file1 = double("file1")
        file2 = double("file2")
        allow(File).to receive(:open).with(subject.source_migration_path).and_return(file2)
        allow(File).to receive(:open).with(subject.script_path, "w").and_return(file1)
        allow(file2).to receive(:readlines).and_return(migration_body)
        allow(file1).to receive(:write).with(subject.render)
        expect(file1).to receive(:close)
        subject.write_script!
    end

    it "can get source script content" do
        src_file = "./spec/fixtures/20140505235630_alter_table_example.rb"
        content = File.open(src_file).readlines.join
        expect(subject.source_script_content).to eq(content) 
    end

    it "can get the 'up' method from a migration" do
        content = "def up\n    percona_alter_table :users, \"ADD COLUMN EMAIL STRING(255)\"\n    percona_alter_table :users, \"ADD COLUMN EMAIL2 STRING(255)\"\n  end"
        expect(subject.source_script_up_method).to eq(content) 
    end
    
    it "can get an array of 'up' method 'percona_alter_table' calls" do
        correct = ["percona_alter_table :users\, \"ADD COLUMN EMAIL STRING(255)\"",
                   "percona_alter_table :users, \"ADD COLUMN EMAIL2 STRING(255)\"" ]

        expect(subject.up_method_alter_table_calls).to eq(correct) 
    end

    it "can determine a table name for alter commands" do
        expect(subject.table_name).to eq("users") 
    end

    it "can get an array of structured alter sql " do
        correct = {table: 'users', alters: ['ADD COLUMN EMAIL STRING(255)', 'ADD COLUMN EMAIL2 STRING(255)']}
        expect(subject.alter_table_calls).to eq(correct) 
    end

    it "errors if you try to generate script with migration that has no percona alters" do
        expect {
            PerconaMigrations::ShellScriptGenerator.new "20150121203928"
        }.to raise_error.with_message("Migration does not have any 'percona_alter_table' calls")
    end

    it "errors if you try to generate script with migration that has no 'up' calls" do
        expect {
            PerconaMigrations::ShellScriptGenerator.new "20130121203928"
        }.to raise_error.with_message("Migration does not have any 'up' calls")
    end

    it "errors if migration is modifying more than one table in it's 'percona_alter_table' calls" do
        expect {
            PerconaMigrations::ShellScriptGenerator.new "20120121203928"
        }.to raise_error.with_message("Migration can not modify more than one table")
    end
end
