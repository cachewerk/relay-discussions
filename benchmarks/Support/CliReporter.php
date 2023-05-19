<?php

namespace CacheWerk\Relay\Benchmarks\Support;

class CliReporter extends Reporter
{
    public function startingBenchmark(Benchmark $benchmark)
    {
        $ops = $benchmark::Operations;
        $revs = $benchmark::Revolutions;

        printf(
            "\nExecuting %d iterations (%d warmup) of %s %s...\n\n",
            $benchmark::Iterations,
            $benchmark::Warmup ?? 'no',
            number_format($ops * $revs),
            $benchmark::Name
        );
    }

    public function finishedIteration(Iteration $iteration)
    {
        $benchmark = $iteration->subject->benchmark;

        $ops = $benchmark::Operations;
        $revs = $benchmark::Revolutions;

        $ops_sec = ($ops * $revs) / ($iteration->ms / 1000);

        printf(
            "Executed %s %s using %s in %sms (%s ops/s) consuming %s transferring %s\n",
            number_format($ops * $revs),
            $benchmark::Name,
            $iteration->subject->client(),
            number_format($iteration->ms, 2),
            $this->humanNumber($ops_sec),
            $this->humanMemory($iteration->memory),
            $this->humanMemory($iteration->bytesIn + $iteration->bytesOut)
        );
    }

    public function finishedSubject(Subject $subject)
    {
        $benchmark = $subject->benchmark;

        $ops = $benchmark::Operations;
        $its = $benchmark::Iterations;
        $revs = $benchmark::Revolutions;
        $name = $benchmark::Name;

        $ms_median = $subject->msMedian();
        $memory_median = $subject->memoryMedian();
        $bytes_median = $subject->bytesMedian();
        $rstdev = $subject->msRstDev();

        $ops_sec = ($ops * $revs) / ($ms_median / 1000);

        printf(
            "Executed %d iterations of %s %s using %s in %sms (%s ops/s) consuming %s transferring %s [±%.2f%%]\n",
            count($subject->iterations),
            number_format($ops * $revs),
            $name,
            $subject->client(),
            number_format($ms_median, 2),
            $this->humanNumber($ops_sec),
            $this->humanMemory($memory_median * $its),
            $this->humanMemory($bytes_median * $its),
            $rstdev
        );
    }

    public function finishedSubjects(Subjects $subjects)
    {
        $subjects = $subjects->sortByTime();
        $baseMsMedian = $subjects[0]->msMedian();

        $i = 0;

        echo "\n";

        foreach ($subjects as $subject) {
            $msMedian = $subject->msMedian();
            $memoryMedian = $subject->memoryMedian();
            $bytesMedian = $subject->bytesMedian();
            $diff = -(1 - ($msMedian / $baseMsMedian)) * 100;
            $multiple = 1 / ($msMedian / $baseMsMedian);

            printf(
                "%s (%sms, memory:%s, network:%s) [%sx, %s%%]\n",
                $subject->client(),
                number_format($msMedian, 2),
                $this->humanMemory($memoryMedian),
                $this->humanMemory($bytesMedian),
                $i === 0 ? '1.0' : number_format($multiple, $multiple < 2 ? 2 : 1),
                $i === 0 ? '0' : number_format($diff, 1),
            );

            $i++;
        }
    }
}
