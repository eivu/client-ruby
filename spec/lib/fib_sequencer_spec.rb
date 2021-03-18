describe FibSequencer do
  describe '#call' do
    subject(:fib_seq) { FibSequencer.call(n) }

    # considering that higher values are based on lower values
    # the only tests you really need are of 2,1 (the bases cases)
    # and 33 the highest case possible.  I added 10 for reasons of "completion"
    # ie just making sure somethihng in the middle works
    context 'success' do
      context 'when n is 1' do
        let(:n) { 1 }

        it { is_expected.to eq(1) }
      end

      context 'when n is 2' do
        let(:n) { 2 }

        it { is_expected.to eq(1) }
      end

      context 'when n is 10' do
        let(:n) { 10 }

        it { is_expected.to eq(55) }
      end

      context 'when n is 33' do
        let(:n) { 33 }

        it { is_expected.to eq(3_524_578) }
      end
    end

    context 'failure' do
      context 'when n is 34' do
        let(:n) { 34 }
        it 'raises an error' do
          expect { fib_seq }.to raise_error(ArgumentError)
        end
      end

      context 'when n is 5000' do
        let(:n) { 5000 }
        it 'raises an error' do
          expect { fib_seq }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
