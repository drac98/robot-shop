<?php

declare(strict_types=1);

namespace Instana\RobotShop\Ratings\Service;

use PDO;
use Psr\Log\LoggerAwareInterface;
use Psr\Log\LoggerAwareTrait;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

/**
 * @Route("/ratservice")
 */
class RatingsService implements LoggerAwareInterface
{
    private const QUERY_RATINGS_BY_SKU = 'select avg_rating, rating_count from ratings where sku = ?';
    private const QUERY_UPDATE_RATINGS_BY_SKU = 'update ratings set avg_rating = ?, rating_count = ? where sku = ?';
    private const QUERY_INSERT_RATING = 'insert into ratings(sku, avg_rating, rating_count) values(?, ?, ?)';

    use LoggerAwareTrait;

    /**
     * @var PDO
     */
    private $connection;
    private $rt_web_get_ratings_sum;
    private $rt_web_get_ratings_count;

    public function __construct(PDO $connection)
    {
        $this->connection = $connection;
        $this->rt_web_get_ratings_sum = 0.0;
        $this->rt_web_get_ratings_count = 0;
    }

    /**
     * @Route("/metrics", methods={"GET"})
     */
    public function metrics(Request $request): Response
    {   $metrics = "rt_web_get_ratings_sum ". strval($this->rt_web_get_ratings_sum). " \nrt_web_get_ratings_count " . strval($this->rt_web_get_ratings_count)."\n";
        header("Content-type: text/plain");
        //echo $metrics;
        return new Response($metrics, 200, ['Content-type' => 'text/plain']);
    }   

    public function ratingBySku(string $sku): array
    {   $start = microtime();
        $stmt = $this->connection->prepare(self::QUERY_RATINGS_BY_SKU);
        if (false === $stmt->execute([$sku])) {
            $this->logger->error('failed to query data');

            throw new \Exception('Failed to query data', 500);
        }

        $data = $stmt->fetch();
        if ($data) {
            // for some reason avg_rating is return as a string
            $data['avg_rating'] = (float) $data['avg_rating'];

            return $data;
        }

        // nicer to return an empty record than throw 404
        $this->rt_web_get_ratings_sum+= microtime()-$start;
        $this->rt_web_get_ratings_count +=1;
        return ['avg_rating' => 0, 'rating_count' => 0];
    }

    public function updateRatingForSKU(string $sku, $score, int $count): void
    {   $start = microtime();
        $stmt = $this->connection->prepare(self::QUERY_UPDATE_RATINGS_BY_SKU);
        if (!$stmt->execute([$score, $count, $sku])) {
            $this->logger->error('failed to update rating');
            throw new \Exception('Failed to update data', 500);
        }
        $this->rt_web_get_ratings_sum+= microtime()-$start;
        $this->rt_web_get_ratings_count +=1;
    }

    public function addRatingForSKU($sku, $rating): void
    {   $start = microtime();
        $stmt = $this->connection->prepare(self::QUERY_INSERT_RATING);
        if (!$stmt->execute([$sku, $rating, 1])) {
            $this->logger->error('failed to insert data');
            throw new \Exception('Failed to insert data', 500);
        }
        $this->rt_web_get_ratings_sum+= microtime()-$start;
        $this->rt_web_get_ratings_count +=1;
    }
}
