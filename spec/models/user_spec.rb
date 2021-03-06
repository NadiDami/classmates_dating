require 'spec_helper'

describe User do
  
  it {should belong_to :school}
  it {should have_many :messages}
  it {should have_many :sent_messages}

  context 'passwords' do
    let(:user) { User.new }
    before do    
      user.password = 'foobar'
    end

    it 'can set a password' do
      expect(user.encrypted_password).not_to be_empty
    end

    it 'encrypts the password' do
      expect(user.encrypted_password.to_s).not_to eq 'foobar'
    end
  end

  context 'valid user' do

    it 'is valid given an email, first name and last name' do
      user = build(:user)
      expect(user).to be_valid
    end

  end

  context 'invalid user' do
    it 'is invalid without an email' do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
    end

    it 'is invalid without a password' do
      user = build(:user, password: nil)
      expect(user).not_to be_valid
    end
  end

  context 'age verification' do
    specify 'users must provide an age' do
      user = build(:user, dob: nil)
      expect(user).to have(1).errors_on(:dob)
    end

    it 'allows users over 18' do
      user = build(:user, dob: 20.years.ago)
      expect(user).to be_valid
    end

    it 'disallows users under 18' do
      user = build(:user, dob: 16.years.ago)
      expect(user).to have(1).errors_on(:dob)
    end
  end

  context 'school_name=' do
    let(:user) { User.new }
    let!(:eton) { create(:school, name: 'Eton') }

    it 'sets the school to an existing one (if it exists)' do
      user.school_name = 'Eton'
      expect(user.school).to eq eton
    end

    it 'creates a new schoool if no similarly named school exists' do
      user.school_name = 'Cambridge'
      expect(user.school).not_to eq eton
      expect(user.school).to be_a School
    end
  end

  context '#login' do
    before do
      @user = create(:user)
    end

    context 'invalid credentials' do

      it 'returns nil given a wrong email' do
        expect(User.login('b@c.com', '12345678')).to eq nil
      end

      it 'returns nil given a wrong password' do
        expect(User.login('nadia@foo.com', '12345609')).to eq nil
      end
    end

    context 'valid credentials' do

      it 'returns the user id given the correct details' do
        expect(User.login('nadia@foo.com', '12345678')).to eq @user.id
      end

    end
  end

  context '.opposite_gender' do

    it 'returns male for a female user' do
      user = create(:user, gender: 'male')
      expect(user.opposite_gender).to eq 'female'
    end

    it 'returns female for a male user' do
      user = create(:user, gender: 'female')
      expect(user.opposite_gender).to eq 'male'
    end

    it 'raises an error given an unknown gender' do
      user = create(:user, gender: 'foo')
      expect { user.opposite_gender }.to raise_error
    end
  end

  context '.of_opposite_gender' do
    let!(:dave) { create(:dave) }
    let!(:brenda) { create(:brenda) }
    let!(:john) { create(:john) }

    it 'returns the students of the opposite gender' do
      female_students = User.of_opposite_gender(dave)
      expect(female_students).to include brenda
      expect(female_students).not_to include john
    end
  end

end
