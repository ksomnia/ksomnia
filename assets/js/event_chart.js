import Chart from 'chart.js/auto'
import 'chartjs-adapter-moment';

const drawChart = (el, data) => {
  new Chart(
    el,
    {
      options: {
        plugins: {
          legend: {
            display: false,
          }
        },
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          x: {
            reverse: true,
            grid: {
              display: false
            },
            type: 'timeseries',
          },
          y: {
            grid: {
              display: false
            }
          }
        }
      },
      type: 'bar',
      data: {
        labels: data.map(row => row.hour),
        datasets: [
          {
            barPercentage: 1.0,
            categoryPercentage : 1.0,
            data: data.map(row => row.count)
          }
        ]
      }
    }
  );
}

export { drawChart }